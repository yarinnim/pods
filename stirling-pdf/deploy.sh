#! /usr/bin/bash

set -e

source ./.env

export STIRLING_PORT=${STIRLING_PORT}
export STIRLING_APP_NAME=${STIRLING_APP_NAME}
export STIRLING_APP_HOME_NAME=${STIRLING_APP_HOME_NAME}
export STIRLING_APP_NAVBAR_NAME=${STIRLING_APP_NAVBAR_NAME}
export STIRLING_BASE_URL=${STIRLING_BASE_URL}
export STIRLING_USER=${STIRLING_USER}
export STIRLING_PASSWORD=${STIRLING_PASSWORD}

mkdir -p ${STIRLING_OCR_PATH}
mkdir -p ${STIRLING_CONFIGS_PATH}
mkdir -p ${STIRLING_LOGS_PATH}
mkdir -p ${STIRLING_PIPELINE_PATH}

export STIRLING_OCR_PATH=${STIRLING_OCR_PATH}
export STIRLING_CONFIGS_PATH=${STIRLING_CONFIGS_PATH}
export STIRLING_LOGS_PATH=${STIRLING_LOGS_PATH}
export STIRLING_PIPELINE_PATH=${STIRLING_PIPELINE_PATH}

echo "[INFO] Deploying as stack..."
docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file docker-compose.yml common
