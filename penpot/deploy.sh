#! /usr/bin/bash

set -e

source ./.env

mkdir -p ${PENPOT_ASSETS_PATH}
chmod -R 0777 ${PENPOT_ASSETS_PATH}

export PENPOT_PUBLIC_URI=${PENPOT_PUBLIC_URI}
export PENPOT_ASSETS_URL=${PENPOT_ASSETS_URL}
export PENPOT_SECRET_KEY=${PENPOT_SECRET_KEY}
export PENPOT_ASSETS_PATH=${PENPOT_ASSETS_PATH}
export PENPOT_DATABASE_URI=${PENPOT_DATABASE_URI}
export PENPOT_DATABASE_USERNAME=${PENPOT_DATABASE_USERNAME}
export PENPOT_DATABASE_PASSWORD=${PENPOT_DATABASE_PASSWORD}
export PENPOT_REDIS_URI=${PENPOT_REDIS_URI}

echo "[INFO] Deploying as stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file docker-compose.yml penpot
