#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Error: PHP Project destination folder path required."
  echo "Usage: $0 /path/to/php-project"
  exit 1
fi

DEST=$1

shopt -s extglob
cp -rfv !(env.example|init-to.sh) $DEST
shopt -u extglob
