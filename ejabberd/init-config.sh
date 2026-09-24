#!/usr/bin/bash

source ./.env

rm -rfv /var/data/ejabberd

# Create host persistent data folders
mkdir -p "${EJABBERD_CONF_PATH}"
mkdir -p "${EJABBERD_DATABASE_PATH}"
mkdir -p "${EJABBERD_LOGS_PATH}"
mkdir -p "${EJABBERD_UPLOAD_PATH}"

# Initialize the Configuration folder
echo "[INFO] Seeding default ejabberd configuration into ${EJABBERD_CONF_PATH}..."
IMG_CONF=$(docker create "${EJABBERD_IMAGE}")
docker cp "${IMG_CONF}:/home/ejabberd/conf/." "${EJABBERD_CONF_PATH}/"
docker rm "${IMG_CONF}"

# Set to use external database
echo "[INFO] Add database configuration..."
CONF_FILE="${EJABBERD_CONF_PATH}/ejabberd.yml"
sed -i "/^loglevel: info/a\\
\\
sql_type: pgsql\\
sql_server: ${EJABBERD_DB_HOST}\\
sql_port: ${EJABBERD_DB_PORT}\\
sql_database: ${EJABBERD_DB_NAME}\\
sql_username: ${EJABBERD_DB_USERNAME}\\
sql_password: ${EJABBERD_DB_PASSWORD}\\
sql_keepalive_interval: 30\\
default_db: sql\\
auth_method: sql\\
update_sql_schema: true\\
oauth_access: all\\
oauth_db_type: mnesia
" "${CONF_FILE}"

# Force correct permissions for UID/GID 9000
# chown -R ejabberd:ejabberd "${EJABBERD_UPLOAD_PATH}"
sudo chown -R 9000:9000 "${EJABBERD_DATABASE_PATH}" "${EJABBERD_LOGS_PATH}" \
  "${EJABBERD_CONF_PATH}" "${EJABBERD_UPLOAD_PATH}"
