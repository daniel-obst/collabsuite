#!/bin/bash

set -e

readonly PLATFORM_VAULT_PASSWORDS_DIR="platform_vault/platform/passwords"
readonly ANSIBLE_KEY="platform_vault/platform/openssh/id_ed25519_ansible-controller.collabsuite.lan"

# Servers #
ansible-playbook -i inventories/production \
    --connection-password-file "${PLATFORM_VAULT_PASSWORDS_DIR}/external_gateways_management_user" \
    --tags "platform_external_gateways_servers" platform.yml

ansible-playbook -i inventories/production \
    --connection-password-file "${PLATFORM_VAULT_PASSWORDS_DIR}/internal_gateways_management_user" \
    --tags "platform_internal_gateways_servers" platform.yml

ansible-playbook -i inventories/production \
    --connection-password-file "${PLATFORM_VAULT_PASSWORDS_DIR}/identity_providers_management_user" \
    --tags "platform_identity_providers_servers" platform.yml

ansible-playbook -i inventories/production \
    --connection-password-file "${PLATFORM_VAULT_PASSWORDS_DIR}/platform_server_1_management_user" \
    --tags "platform_server_1_servers" platform.yml

ansible-playbook -i inventories/production \
    --connection-password-file "${PLATFORM_VAULT_PASSWORDS_DIR}/platform_server_2_management_user" \
    --tags "platform_server_2_servers" platform.yml

ansible-playbook -i inventories/production \
    --connection-password-file "${PLATFORM_VAULT_PASSWORDS_DIR}/platform_server_3_management_user" \
    --tags "platform_server_3_servers" platform.yml

# Services #
ansible-playbook -i inventories/production --tags "services_quay_io" platform.yml