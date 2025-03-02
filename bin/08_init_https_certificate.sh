#!/bin/bash

set -e

ansible-playbook -i inventories/production --tags "services_external_gateway_certbot" platform.yml
echo -e '\nSleeping 10 seconds before copying "letsencrypt" directory to "platform_vault/platform" ...'
sleep 10
echo -e 'Copying "letsencrypt" directory to "platform_vault/platform"\n'
scp -r -i "platform_vault/platform/openssh/id_ed25519_certbot-service.collabsuite.lan" \
  certbot@ext-gw.collabsuite.lan:conf.d/letsencrypt platform_vault/platform