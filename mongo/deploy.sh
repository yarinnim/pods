#! /usr/bin/bash

source ./.env

mkdir -p "${MONGO_PATH}/db"
mkdir -p "${MONGO_PATH}/configdb"

export MONGO_PATH=${MONGO_PATH}

docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --compose-file docker-compose.yml common
