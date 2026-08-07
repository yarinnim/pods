#! /usr/bin/bash

set -e

source ./.env

mkdir -p ${POSTGRES_VOLUME_PATH}
mkdir -p ${POSTGRES_ARCHIVE_PATH}
mkdir -p ${POSTGRES_DUMP_PATH}
mkdir -p ${SSH_KEYS_PATH}
chmod -R 0777 ${POSTGRES_ARCHIVE_PATH}

export POSTGRES_PORT=${POSTGRES_PORT}
export POSTGRES_USER=${POSTGRES_USER}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
export POSTGRES_DB=${POSTGRES_DB}
export POSTGRES_IMAGE=${POSTGRES_IMAGE}
export POSTGRES_VOLUME_PATH=${POSTGRES_VOLUME_PATH}
export POSTGRES_ARCHIVE_PATH=${POSTGRES_ARCHIVE_PATH}
export POSTGRES_DUMP_PATH=${POSTGRES_DUMP_PATH}
export SSH_KEYS_PATH=${SSH_KEYS_PATH}

DOCKER_COMPOSE=docker-compose.yml
DOCKER_COMPOSE_OUT="tmp-${DOCKER_COMPOSE}"

cat $DOCKER_COMPOSE | sed -e "s/{SERVICE_NAME}/${SERVICE_NAME}/g" > $DOCKER_COMPOSE_OUT

echo "[INFO] Pulling image (${POSTGRES_IMAGE}) from docker..."
docker pull "${POSTGRES_IMAGE}"

echo "[INFO] Deploying as stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file $DOCKER_COMPOSE_OUT common
