#!/bin/bash

set -e

get_private_ip () {
  PRIVATE_IP="$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)"

  if [ -z $PRIVATE_IP ]; then
    # hostname -I returns all IP addresses available in the server, grep will return the first private IP found
    PRIVATE_IP="$(hostname -I | tr ' ' '\n' | grep -m 1 -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)')"
  fi

  echo $PRIVATE_IP
  return 0
}

# Config /etc/teleport

## Get token for IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 30")

## Get private IP for advertise_ip
echo "ADVERTISE_IP=$(get_private_ip)" >> /etc/teleport

## Get instance ID (if possible)
${include_instance_id ? "export INSTANCE_ID=-$(curl -s -H \"X-aws-ec2-metadata-token: $TOKEN\" http://169.254.169.254/latest/meta-data/instance-id)" : ""}

## Set the rest of the config
echo "AUTH_TOKEN=${auth_token}" >> /etc/teleport
echo "AUTH_SERVER=${auth_server}" >> /etc/teleport
echo "NODENAME=${function}${project}${environment}$INSTANCE_ID" >> /etc/teleport

# Reload systemd to activate teleport service
sudo systemctl daemon-reload

# Enable teleport service
sudo systemctl enable teleport.service

# Start teleport service
sudo systemctl start teleport.service
