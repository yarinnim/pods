#! /usr/bin/bash

source ./.env

mkdir -p ${PORTAINER_DATA}

export PORTAINER_IMAGE=${PORTAINER_IMAGE}
export PORTAINER_API_PORT=${PORTAINER_API_PORT}
export PORTAINER_HTTP_PORT=${PORTAINER_HTTP_PORT}
export PORTAINER_HTTPS_PORT=${PORTAINER_HTTPS_PORT}
export PORTAINER_DATA=${PORTAINER_DATA}

docker stack deploy \
  --detach=false \
  -c portainer-agent-stack.yml portainer 
