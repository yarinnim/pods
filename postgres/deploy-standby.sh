#! /usr/bin/bash

set -e

source ./.env-standby

mkdir -p ${POSTGRES_VOLUME_PATH}
mkdir -p ${POSTGRES_ARCHIVE_PATH}
chmod -R 0777 ${POSTGRES_ARCHIVE_PATH}
chmod -R 0777 ${POSTGRES_VOLUME_PATH}

export POSTGRES_PORT=${POSTGRES_PORT}
export POSTGRES_IMAGE=${POSTGRES_IMAGE}
export POSTGRES_VOLUME_PATH=${POSTGRES_VOLUME_PATH}
export POSTGRES_ARCHIVE_PATH=${POSTGRES_ARCHIVE_PATH}
export POSTGRES_DUMP_PATH=${POSTGRES_DUMP_PATH}
export POSTGRES_USER=${POSTRES_USER}
export POSTGRES_PASSWORD=${POSGRES_PASSWORD}

export PRIMARY_HOST=${PRIMARY_HOST}
export PRIMARY_PORT=${PRIMARY_PORT}
export REPLICA_USER=${REPLICA_USER}
export REPLICA_PASSWORD=${REPLICA_PASSWORD}

DOCKER_COMPOSE=docker-compose_standby.yml
DOCKER_COMPOSE_OUT="tmp-${DOCKER_COMPOSE}"
DOCKER_COMPOSE_INIT=docker-compose_standby-init.yml
DOCKER_COMPOSE_INIT_OUT="tmp-${DOCKER_COMPOSE_INIT}"

function change_service_name() {
  cat $DOCKER_COMPOSE | sed -s "s/{SERVICE_NAME}/${SERVICE_NAME}/g" > $DOCKER_COMPOSE_OUT
  cat $DOCKER_COMPOSE_INIT | sed -s "s/{SERVICE_NAME}/${SERVICE_NAME}/g" > $DOCKER_COMPOSE_INIT_OUT
}

function pull_image() {
  echo "[INFO] Pulling image (${POSTGRES_IMAGE}) from docker..."
  docker pull "${POSTGRES_IMAGE}"
}

function deploy_standby() {
  echo "[INFO] Deploying as stack..."
  docker stack deploy --with-registry-auth \
    --resolve-image=always \
    --compose-file ${DOCKER_COMPOSE_OUT} common
}

function init_standby() {
  echo "[INFO] Deploying as stack..."
  docker compose \
    --file "${DOCKER_COMPOSE_OUT}" \
    --file ${DOCKER_COMPOSE_INIT_OUT} config

  docker stack deploy --with-registry-auth \
    --detach=false \
    --resolve-image=always \
    --compose-file "${DOCKER_COMPOSE_OUT}" \
    --compose-file ${DOCKER_COMPOSE_INIT_OUT} common
}

change_service_name

ACTION=$1
if [ -z "${ACTION}" ]; then
  echo "[ERRO] Invalid command [startup, deploy]"
  echo "[HINT] $> sudo ./deploy-stand.by startup|deploy"
  exit 1
fi

if [ "${ACTION}" = "startup" ]; then
  init_standby
  exit 1
fi

if [ "${ACTION}" = "deploy" ]; then
  deploy_standby
  exit 1
fi

echo "[ERROR] Command [${ACTION}] not found"
