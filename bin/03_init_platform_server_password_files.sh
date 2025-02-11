#!/bin/bash

set -e

function die() {
  echo "${1}"
  exit 1
}

readonly BASE_PASSWORD_PATH="platform_vault/platform/passwords"
declare -ar PASSWORD_FILES=(
  "ansible_controllers_management_user"
  "domain_name_providers_management_user"
  "external_gateways_management_user"
  "internal_gateways_management_user"
  "identity_providers_management_user"
  "platform_server_1_management_user"
  "platform_server_2_management_user"
  "platform_server_3_management_user"
)

read -s -p "Please enter the management user password: " passwd_1
echo ""
read -s -p "Please re-enter the management user password: " passwd_2
echo ""

[[ "$passwd_1" == "$passwd_2" ]] || die "Entered passwords are different"
[ -z "$passwd_1" ] && die "Password cannot be empty"

mkdir -p "${BASE_PASSWORD_PATH}"
umask 077

for i in "${PASSWORD_FILES[@]}";
do
  echo "Password: [${BASE_PASSWORD_PATH}/$i]"
  echo -n "$passwd_1" > "${BASE_PASSWORD_PATH}/$i"
done