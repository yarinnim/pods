#!/bin/bash

set -e

source ../.env

# Get databases and store in array

DB=$1
DUMP_FILE_NAME="${DB}-$(date +%Y%m%d-%H%M%S).sql"
DUMP_FILE_PATH="../${POSTGRES_DUMP_PATH}/${DUMP_FILE_NAME}"

echo ""
echo "[INFO] Dumping ${DUMP_FILE_PATH}"

export PGPASSWORD="${POSTGRES_PASSWORD}"
pg_dump --username=${POSTGRES_USER} --dbname=${DB} --host=${POSTGRES_HOST} --port=${POSTGRES_PORT} \
  --inserts \
  --file="${DUMP_FILE_PATH}"

unset PGPASSWORD

echo "[INFO] Backup completed for ${db}"
