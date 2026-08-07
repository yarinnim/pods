#! /usr/bin/bash

set -e

source ./.env

mkdir -p "${AISTOR_DATA_PATH}"

export AISTOR_API_PORT=${AISTOR_API_PORT}
export AISTOR_CONSOLE_PORT=${AISTOR_CONSOLE_PORT}
export AISTOR_ROOT_USER=${AISTOR_ROOT_USER}
export AISTOR_ROOT_PASSWORD=${AISTOR_ROOT_PASSWORD}
export AISTOR_DATA_PATH=${AISTOR_DATA_PATH}
export AISTOR_LICENSE_FILE=${AISTOR_LICENSE_FILE}

export AISTOR_BROWSER_REDIRECT_URL=${AISTOR_BROWSER_REDIRECT_URL}
export AISTOR_SERVER_URL=${AISTOR_SERVER_URL}

echo "[INFO] Deploying as stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file docker-compose.yml common
