#!/usr/bin/bash

set -e

source ./.env

REGISTRY_USER=${REGISTRY_USER:-admin}
REGISTRY_PASS=${REGISTRY_PASS:-admin123}

mkdir -p ./data ./auth

# 1. Generate htpasswd file using httpd:2 image (-Bbn outputs directly to file)
docker run --rm --entrypoint htpasswd httpd:2 -Bbn "${REGISTRY_USER}" "${REGISTRY_PASS}" > ./auth/htpasswd

# 2. Deploy Swarm Stack
echo "[INFO] Deploying stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file docker-compose.yml registry
