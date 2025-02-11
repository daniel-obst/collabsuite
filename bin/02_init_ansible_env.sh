#!/bin/bash

set -e

readonly VIRTUAL_ENV_ANSIBLE="./virtualenv/ansible"

python3 -m venv "${VIRTUAL_ENV_ANSIBLE}"
source "${VIRTUAL_ENV_ANSIBLE}/bin/activate"
pip3 install ansible ansible-lint netaddr passlib dnspython pip_system_certs jmespath
ansible-galaxy collection install ansible.utils community.general infra.quay_configuration
deactivate