#!/bin/sh

set -e

source ./.env

if [ ! -f ${POSTGRES_RESTORE_FILE} ]; then
  echo "[ERROR] Restore file (${POSTGRES_RESTORE_FILE}) not exists."
  exit 1
fi

echo "[INFO] Restoring a dump file ${POSTGRES_RESTORE_FILE}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
psql --host=${POSTRES_HOST} --port=${POSTRES_PORT} \
  --username=${POSTGRES_USER} --dbname=${POSTGRES_DB} \
  < ${POSTGRES_RESTORE_FILE}
echo "[INFO] Restore completed"
unset PGPASSWORD
