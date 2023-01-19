#!/bin/sh

# Ingress

export STATIC_IP_ADDRESS_NAME=$(terraform -chdir=../terraform output -raw static_ip_name)

envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < ../templates/ingress.yaml >> ../kubernetes/cloud-provider/ingress.yaml