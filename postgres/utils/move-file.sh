#!/bin/bash

set -e

source ./common.sh

FILES=($(get_dump_files))

if [ ${#FILES[@]} -eq 0 ]; then
  echo "[INFO] No backup file left to be moved."
  exit 1
fi

for FILE in "${FILES[@]}"; do
  FILE_NAME=$(basename ${FILE})
  DEST_FILE=${BACKUP_PATH}/${FILE_NAME}

  if [ $(destination_file_exists ${DEST_FILE}) -eq 1 ]; then
    echo "[INFO] File (${FILE_NAME}) already stored at backup server..."
    echo "[WARNING] Deleting local backup file (${FILE_NAME})..."
    rm -rf ${FILE}
    exit 1
  fi

  echo "[INFO] Copying ${FILE} to ${BACKUP_PATH}..."
  scp -i ${SSH_PRIVATE_KEY} ${FILE} ${BACKUP_USER}@${BACKUP_HOST}:${DEST_FILE}
  rm -rf ${FILE}
done