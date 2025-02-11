#!/bin/bash

set -e

readonly CODE_SERVER_VERSION="4.96.2"
readonly CODE_SERVER_BUILD_NUMBER=0

readonly REGISTRY_HOST="server-1.collabsuite.lan:443"
readonly REGISTRY_PATH="$REGISTRY_HOST/collabsuite/platform/v2.0"
readonly CODE_SERVER_CONTAINER_TAG="${REGISTRY_PATH}/linuxserver/code-server:${CODE_SERVER_VERSION}-${CODE_SERVER_BUILD_NUMBER}"

readonly CONTAINER_FILE="
FROM docker.io/linuxserver/code-server:${CODE_SERVER_VERSION}\n
USER root\n
RUN apt-get update\n
RUN apt-get install -y python3 python3-venv python3-pip bash-completion vim\n
RUN apt-get clean\n
RUN rm -rf /var/lib/apt/lists/* /root/.cache"

podman manifest exists "${CODE_SERVER_CONTAINER_TAG}" && podman manifest rm "${CODE_SERVER_CONTAINER_TAG}"
podman manifest create "${CODE_SERVER_CONTAINER_TAG}"

echo "podman build --force-rm --platform linux/amd64 --format oci --manifest "${CODE_SERVER_CONTAINER_TAG}" \
  -f < <(echo -e '${CONTAINER_FILE}' ."

podman build --force-rm --platform linux/amd64 --format oci --manifest "${CODE_SERVER_CONTAINER_TAG}" -f - < <(echo -e "${CONTAINER_FILE}")

podman login --username "$1" --password "$2" --tls-verify=true "$REGISTRY_HOST"
podman manifest push --tls-verify=true "${CODE_SERVER_CONTAINER_TAG}"
podman logout "$REGISTRY_HOST"

podman manifest rm "${CODE_SERVER_CONTAINER_TAG}"
podman image prune -f