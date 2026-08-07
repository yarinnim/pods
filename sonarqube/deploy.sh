#!/usr/bin/bash

source ./.env

# Export variables
export SONARQUBE_IMAGE=${SONARQUBE_IMAGE}
export SONARQUBE_PORT=${SONARQUBE_PORT}

export SONAR_DB_HOST=${SONAR_DB_HOST}
export SONAR_DB_PORT=${SONAR_DB_PORT}
export SONAR_DB_NAME=${SONAR_DB_NAME}
export SONAR_DB_USER=${SONAR_DB_USER}
export SONAR_DB_PASSWORD=${SONAR_DB_PASSWORD}

export SONAR_HOST=${SONAR_HOST}

# Deploy the stack
docker stack deploy \
  --with-registry-auth \
  --resolve-image=always \
  --compose-file docker-compose.yml common


