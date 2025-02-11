#!/bin/bash

set -e

function die() {
  echo "${1}"
  exit 1
}

readonly BASE_PASSWORD_PATH="platform_data/platform"

read -p "Please enter the PKI - common name: " common_name_1
read -p "Please re-enter the PKI - common name: " common_name_2
echo ""

[[ "$common_name_1" == "$common_name_2" ]] || die "Entered PKI common names are different"
[ -z "$common_name_1" ] && die "PKI common name cannot be empty"

mkdir -p "${BASE_PASSWORD_PATH}"
umask 077

echo "PKI common name: [${BASE_PASSWORD_PATH}/ca_common_name]"
echo "${common_name_1}" > "${BASE_PASSWORD_PATH}/ca_common_name"