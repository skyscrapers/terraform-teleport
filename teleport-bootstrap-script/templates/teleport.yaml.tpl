ssh_service:
  enabled: yes
  listen_addr: 0.0.0.0:3022

  labels:
    environment: "${environment}"
    function: "${function}"
    project: "${project}"
    ${additional_labels}

  permit_user_env: false
auth_service:
  enabled: no
proxy_service:
  enabled: no
