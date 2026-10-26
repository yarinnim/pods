#!/bin/sh
set -e

if [ -n "${WORKER_COMMAND}" ]; then
  exec sh -c "${WORKER_COMMAND}"
fi

if [ ! -f /var/www/artisan ]; then
  echo "worker: no WORKER_COMMAND and /var/www/artisan is missing; worker disabled"
  exec sleep infinity
fi

if [ "${QUEUE_CONNECTION:-sync}" = "sync" ]; then
  echo "worker: QUEUE_CONNECTION=sync; queue worker idle"
  exec sleep infinity
fi

exec php /var/www/artisan queue:work --sleep=3 --tries=3 --max-time=3600
