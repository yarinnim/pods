#! /usr/bin/bash

set -e

source ./.env-pgadmin

mkdir -p ${PGADMIN_DATA}
chmod -R 0777 ${PGADMIN_DATA}

export PGADMIN_DATA=${PGADMIN_DATA}
export PGADMIN_PORT=${PGADMIN_PORT}
export PGADMIN_EMAIL=${PGADMIN_EMAIL}
export PGADMIN_PASSWORD=${PGADMIN_PASSWORD}

echo "[INFO] Deploying as stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file pgadmin.yml common
