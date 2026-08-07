#! /usr/bin/bash

source ./.env

# Keycloak image and admin credentials
export KEYCLOAK_IMAGE=${KEYCLOAK_IMAGE}
export KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN}
export KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}
export KEYCLOAK_PORT=${KEYCLOAK_PORT}

# Postgres database for Keycloak
export KEYCLOAK_DB_VENDOR=${KEYCLOAK_DB_VENDOR}
export KEYCLOAK_DB_ADDR=${KEYCLOAK_DB_ADDR}
export KEYCLOAK_DB_PORT=${KEYCLOAK_DB_PORT}
export KEYCLOAK_DB_DATABASE=${KEYCLOAK_DB_DATABASE}
export KEYCLOAK_DB_USER=${KEYCLOAK_DB_USER}
export KEYCLOAK_DB_PASSWORD=${KEYCLOAK_DB_PASSWORD}

export KEYCLOAK_HOSTNAME=${KEYCLOAK_HOSTNAME}
# Deploy the stack
docker stack deploy \
  --with-registry-auth \
  --resolve-image=always \
  --compose-file docker-compose.yml common
