#!/bin/bash

set -e

readonly PLATFORM_VAULT_DIR="platform_vault"
readonly PLATFORM_DATA_DIR="platform_data"
readonly PLATFORM_ENVIRONMENT_FILE_PATH="${PLATFORM_DATA_DIR}/platform/platform_environment.yml"
readonly PLATFORM_ENVIRONMENT_FILE_CONTENTS='''---
external_server:
  production:
    ip: "<external IP address>"
    platform_internal_network_dns: "<platform internal network DNS IP>"
  staging:
    ip: "<external IP address>"
    platform_internal_network_dns: "<platform internal network DNS IP>"
'''

function run_cmd() {
  echo -e "\n*** [$(date)]: ${1}"
  eval "${1}"
}

function setup_platform_environment_file () {
  if [ -f "${PLATFORM_ENVIRONMENT_FILE_PATH}" ]; then
    echo -e "\n*** [$(date)]: ${PLATFORM_ENVIRONMENT_FILE_PATH} exists, skipping file creation"
  else
    echo -e "\n*** [$(date)]: ${PLATFORM_ENVIRONMENT_FILE_PATH} not found, creating initial file"
    echo -e "${PLATFORM_ENVIRONMENT_FILE_CONTENTS}" > "${PLATFORM_ENVIRONMENT_FILE_PATH}"
  fi

  echo -e \
"\n***********************************************************************************************************************
* Must update ${PLATFORM_ENVIRONMENT_FILE_PATH} with required settings before initializing the platform *
***********************************************************************************************************************"
}

run_cmd "sudo apt-get update"
run_cmd "sudo apt-get upgrade"
run_cmd "sudo apt-get install easy-rsa podman buildah qemu-user-static jq python3.12-venv sshpass"
run_cmd "mkdir -p ${PLATFORM_VAULT_DIR}/platform/init_locks"
run_cmd "mkdir -p ${PLATFORM_DATA_DIR}/platform"
setup_platform_environment_file