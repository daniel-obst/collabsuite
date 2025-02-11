#!/bin/bash

set -e

readonly PLATFORM_VAULT_PASSWORDS_DIR="platform_vault/platform/passwords"
readonly ANSIBLE_KEY="platform_vault/platform/openssh/id_ed25519_ansible-controller.collabsuite.lan"
readonly REGISTRY_USERNAME="collabsuite"
readonly REGISTRY_PASSWORD="$(cat ${PLATFORM_VAULT_PASSWORDS_DIR}/quay_io_collabsuite)"

ssh -i "${ANSIBLE_KEY}" ansible@server-3.collabsuite.lan 'bash -s' < bin/init_keycloak_container_image.sh "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD"
ssh -i "${ANSIBLE_KEY}" ansible@server-3.collabsuite.lan 'bash -s' < bin/init_code_server_container_image.sh "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD"