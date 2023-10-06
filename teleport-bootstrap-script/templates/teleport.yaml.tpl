ssh_service:
  enabled: yes
  listen_addr: 0.0.0.0:3022

  labels:
    ${labels}

  commands:
    - name: teleport_version
      command:
        ["/bin/bash", "-c", "/usr/local/bin/teleport version | cut -d' ' -f2"]
      period: 1h0m0s
    - name: instance_type
      command:
        [
          "/bin/bash",
          "-c",
          'TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 30") && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type',
        ]
      period: 1h0m0s

  permit_user_env: false
auth_service:
  enabled: no
proxy_service:
  enabled: no
