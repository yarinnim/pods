#!/usr/bin/bash

source ./.env
# Ensure persistent host directories exist
mkdir -p "${GITLAB_CONFIG_DIR}"
mkdir -p "${GITLAB_LOGS_DIR}"
mkdir -p "${GITLAB_DATA_DIR}"

export GITLAB_IMAGE=${GITLAB_IMAGE}
export GITLAB_HOSTNAME=${GITLAB_HOSTNAME}
export GITLAB_EXTERNAL_URL=${GITLAB_EXTERNAL_URL}

export GITLAB_HTTP_PORT=${GITLAB_HTTP_PORT}
export GITLAB_HTTPS_PORT=${GITLAB_HTTPS_PORT}
export GITLAB_SSH_PORT=${GITLAB_SSH_PORT}

export GITLAB_CONFIG_DIR=${GITLAB_CONFIG_DIR}
export GITLAB_LOGS_DIR=${GITLAB_LOGS_DIR}
export GITLAB_DATA_DIR=${GITLAB_DATA_DIR}

docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --compose-file docker-compose.yml common
