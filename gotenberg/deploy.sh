#! /usr/bin/bash

set -e

source ./.env

export GOTENBERG_PORT=${GOTENBERG_PORT}
export GOTENBERG_FONTS_PATH=${GOTENBERG_FONTS_PATH}

echo "[INFO] Deploying as stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file docker-compose.yml common
