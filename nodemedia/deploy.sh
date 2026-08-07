#! /usr/bin/bash

source ./.env

export NODEMEDIA_IMAGE=${NODEMEDIA_IMAGE}
export NODEMEDIA_RTMP_PORT=${NODEMEDIA_RTMP_PORT}
export NODEMEDIA_HTTP_PORT=${NODEMEDIA_HTTP_PORT}

docker stack deploy --with-registry-auth \
  --resolve-image=always \
  -c docker-compose.yml nodemedia

