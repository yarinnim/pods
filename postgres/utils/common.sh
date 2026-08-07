#!/bin/bash

set -e

source ../.env

function get_databases() {
  local IFS=','
  read -ra DATABASES <<< "${BACKUP_DATABASES}"
  echo "${DATABASES[@]}"
}

function destination_file_exists() {
  local DEST_FILE=$1
  EXISTS=$(ssh -i ${SSH_PRIVATE_KEY} ${BACKUP_USER}@${BACKUP_HOST} "[ -e '${DEST_FILE}' ] && echo 'exists' || echo 'not_exists'")
  if [ "${EXISTS}" == "exists" ]; then
    echo 1
  else
    echo 0
  fi
}

function get_dump_files() {
  local FILES=()
  shopt -s nullglob  # Treat patterns with no matches as empty
  FILES=("${POSTGRES_DUMP_PATH}"/*)
  shopt -u nullglob
  echo "${FILES[@]}"
}

function has_files() {
  local FILES=$1
  if [ ${#FILES[@]} -eq 0 ]; then
    echo 0
  else
    echo 1
  fi
}

function get_dump_file() {
  local FILES=($(get_dump_files))
  echo "${FILES[0]}"
}
