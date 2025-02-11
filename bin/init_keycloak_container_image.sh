#!/bin/bash

set -e

readonly OPENJDK_IMAGE_TAG="21.0.5_11-jre-noble"
readonly KEYCLOAK_VERSION="26.0.1"
readonly KEYCLOAK_BUILD_NUMBER=0

readonly REGISTRY_HOST="server-1.collabsuite.lan:443"
readonly REGISTRY_PATH="$REGISTRY_HOST/collabsuite/platform/v2.0"
readonly KEYCLOAK_CONTAINER_TAG="${REGISTRY_PATH}/keycloak:${KEYCLOAK_VERSION}-${KEYCLOAK_BUILD_NUMBER}"

readonly CONTAINERFILE='
# Build stage #
ARG OPENJDK_IMAGE
FROM $OPENJDK_IMAGE as build

ARG KEYCLOAK_WORKDIR
WORKDIR $KEYCLOAK_WORKDIR

ARG KEYCLOAK_VERSION
COPY keycloak-$KEYCLOAK_VERSION .

ARG KEYCLOAK_RELATIVE_PATH
ARG KEYCLOAK_JAVA_OPTS_APPEND

ARG KEYCLOAK_DB
ENV KC_DB=$KEYCLOAK_DB

ENV KC_HTTP_RELATIVE_PATH=$KEYCLOAK_RELATIVE_PATH
ENV JAVA_OPTS_APPEND=$KEYCLOAK_JAVA_OPTS_APPEND

RUN bin/kc.sh build

# Configuration stage #
FROM $OPENJDK_IMAGE

ARG KEYCLOAK_RELATIVE_PATH
ARG KEYCLOAK_JAVA_OPTS_APPEND

LABEL collabsuite.platform.v2.0.java=$OPENJDK_IMAGE
LABEL collabsuite.platform.v2.0.keycloak=keycloak-$VERSION
LABEL collabsuite.platform.v2.0.keycloak.relative_path=$KEYCLOAK_RELATIVE_PATH
LABEL collabsuite.platform.v2.0.keycloak.java_opts_append=$KEYCLOAK_JAVA_OPTS_APPEND
LABEL collabsuite.platform.v2.0.db=$KEYCLOAK_DB

ARG KEYCLOAK_WORKDIR
WORKDIR $KEYCLOAK_WORKDIR

COPY --from=build $KEYCLOAK_WORKDIR .

#EXPOSE $KEYCLOAK_HTTPS_PORT
VOLUME $KEYCLOAK_WORKDIR/data
VOLUME $KEYCLOAK_WORDIR/tls

ENTRYPOINT ["bin/kc.sh", "start", "--optimized", "--proxy-headers", "xforwarded"]'

readonly ARG_OPENJDK_IMAGE="docker.io/eclipse-temurin:$OPENJDK_IMAGE_TAG"
readonly ARG_KEYCLOAK_WORKDIR="/opt/keycloak"
readonly ARG_KEYCLOAK_VERSION="$KEYCLOAK_VERSION"
readonly ARG_KEYCLOAK_RELATIVE_PATH="/auth"
readonly ARG_KEYCLOAK_JAVA_OPTS_APPEND="-Djava.net.preferIPv4Stack=true"
readonly ARG_KEYCLOAK_DB="postgres"

readonly KEYCLOAK_PACKAGE="keycloak-${KEYCLOAK_VERSION}"
readonly KEYCLOAK_TAR_FILE="${KEYCLOAK_PACKAGE}.tar.gz"
readonly KEYCLOAK_SIG_FILE="${KEYCLOAK_TAR_FILE}.sha1"
readonly KEYCLOAK_BASE_URL="https://github.com/keycloak/keycloak/releases/download"
readonly KEYCLOAK_PACKAGE_URL="${KEYCLOAK_BASE_URL}/${KEYCLOAK_VERSION}/${KEYCLOAK_TAR_FILE}"
readonly KEYCLOAK_SIG_URL="${KEYCLOAK_BASE_URL}/${KEYCLOAK_VERSION}/${KEYCLOAK_SIG_FILE}"

[ -f "$KEYCLOAK_TAR_FILE" ] || curl -L --get "$KEYCLOAK_PACKAGE_URL" -o "$KEYCLOAK_TAR_FILE"
[ -f "$KEYCLOAK_SIG_FILE" ] || curl -L --get "$KEYCLOAK_SIG_URL" -o "$KEYCLOAK_SIG_FILE"

echo "`cat $KEYCLOAK_SIG_FILE` $KEYCLOAK_TAR_FILE" | sha1sum -c - --quiet
[ -d "$KEYCLOAK_PACKAGE" ] || tar -xvzf "$KEYCLOAK_TAR_FILE" 

echo "${CONTAINERFILE}" > Containerfile

podman manifest exists "${KEYCLOAK_CONTAINER_TAG}" && podman manifest rm "${KEYCLOAK_CONTAINER_TAG}"
podman manifest create "${KEYCLOAK_CONTAINER_TAG}"

echo "podman build --force-rm --platform linux/amd64 --format oci --manifest "${KEYCLOAK_CONTAINER_TAG}" \
  --build-arg=OPENJDK_IMAGE="$ARG_OPENJDK_IMAGE" \
  --build-arg=KEYCLOAK_WORKDIR="$ARG_KEYCLOAK_WORKDIR" \
  --build-arg=KEYCLOAK_VERSION="$ARG_KEYCLOAK_VERSION" \
  --build-arg=KEYCLOAK_RELATIVE_PATH="$ARG_KEYCLOAK_RELATIVE_PATH" \
  --build-arg=KEYCLOAK_JAVA_OPTS_APPEND="$ARG_KEYCLOAK_JAVA_OPTS_APPEND" \
  --build-arg=KEYCLOAK_DB="$ARG_KEYCLOAK_DB" \
  -f Containerfile ."

podman pull --platform linux/amd64 "$ARG_OPENJDK_IMAGE"
podman build --force-rm --platform linux/amd64 --format oci --manifest "${KEYCLOAK_CONTAINER_TAG}" \
  --build-arg=OPENJDK_IMAGE="$ARG_OPENJDK_IMAGE" \
  --build-arg=KEYCLOAK_WORKDIR="$ARG_KEYCLOAK_WORKDIR" \
  --build-arg=KEYCLOAK_VERSION="$ARG_KEYCLOAK_VERSION" \
  --build-arg=KEYCLOAK_RELATIVE_PATH="$ARG_KEYCLOAK_RELATIVE_PATH" \
  --build-arg=KEYCLOAK_JAVA_OPTS_APPEND="$ARG_KEYCLOAK_JAVA_OPTS_APPEND" \
  --build-arg=KEYCLOAK_DB="$ARG_KEYCLOAK_DB" \
  -f "$CONTAINER_FILE" .

podman login --username "$1" --password "$2" --tls-verify=true "$REGISTRY_HOST"
podman manifest push --tls-verify=true "${KEYCLOAK_CONTAINER_TAG}"
podman logout "$REGISTRY_HOST"

podman image prune -f
podman manifest rm "${KEYCLOAK_CONTAINER_TAG}"

rm -Rf "${KEYCLOAK_PACKAGE}"