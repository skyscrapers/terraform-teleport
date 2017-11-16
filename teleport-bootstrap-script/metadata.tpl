#!/bin/bash

set -e

# Config /etc/teleport

## Get private IP for advertise_ip
export ADVERTISE_IP="$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')"

## Get instance ID (if possible)
${include_instance_id == "true" ? "export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" : ""}

## Set the rest of the config
export AUTH_TOKEN=${auth_token}
export AUTH_SERVER=${auth_server}
export NODENAME=${function}${project}${environment}$INSTANCE_ID

envsubst < "/etc/teleport.yaml" > "/etc/teleport_new.yaml"
mv /etc/teleport_new.yaml /etc/teleport.yaml

# Enable teleport service
sudo systemctl enable teleport.service

# Start teleport service
sudo systemctl start teleport.service
