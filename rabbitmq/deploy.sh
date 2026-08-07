#! /usr/bin/bash

source ./.env

export RABBITMQ_IMAGE=${RABBITMQ_IMAGE}
export RABBITMQ_USER=${RABBITMQ_USER}
export RABBITMQ_PASS=${RABBITMQ_PASS}
export RABBITMQ_VHOST=${RABBITMQ_VHOST}
export RABBITMQ_PORT=${RABBITMQ_PORT}
export RABBITMQ_MANAGEMENT_PORT=${RABBITMQ_MANAGEMENT_PORT}

docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --compose-file docker-compose.yml common
