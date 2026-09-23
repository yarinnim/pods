#!/usr/bin/bash

source ./.env
URL="${SERVER_URL}/api/registered_users?host=${VIRTUAL_HOST}"
echo ${URL}
curl -v $URL
