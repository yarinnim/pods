#! /usr/bin/bash

source ./.env-redisinsight

mkdir -p ${REDISINSIGHT_DATA}
mkdir -p tmp

export REDISINSIGHT_DATA=${REDISINSIGHT_DATA}
export REDISINSIGHT_PORT=${REDISINSIGHT_PORT}

docker stack deploy --with-registry-auth \
  --resolve-image=always \
  --compose-file redisinsight.yml common
