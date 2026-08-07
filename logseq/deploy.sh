#!/usr/bin/bash

docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --compose-file docker-compose.yml common
