#!/bin/bash

set -e

source ./virtualenv/ansible/bin/activate
ansible-playbook -i inventories/production/ --tags "ansible_controllers" platform.yml
sudo cp platform_vault/platform/easyrsa/pki/ca.crt /usr/local/share/ca-certificates/
sudo /usr/sbin/update-ca-certificates -v
deactivate