# ejabberd
This project sets up ejabberd inside our Docker Swarm system. ejabberd is a
powerful, open-source chat server. It allows apps to send instant messages,
data, and real-time updates using two main communication rules: XMPP and MQTT.

## Features

- **Instant Messaging**: It lets you build chat apps, send direct messages, or create group chats easily.
- **Real-Time Data**: It moves data instantly between users, mobile apps, and servers with very little delay.
- **Handles Heavy Traffic**: It is famous for being incredibly stable. It can handle millions of active users and connections at the same time without crashing.
- **Smart Device Communication (IoT)**: Because it supports MQTT, it can talk easily to smart home devices, sensors, and other hardware equipment.

## Pre-Installation

### Initialize Database

As the design is to support the PostgreSQL database, we need to configure the database
to support that. By default the datbase schema for ejabberd is hosted on its official
website. To get the postgresql database schema, run the following:

```bash
# RAW Database schema
# https://raw.githubusercontent.com/processone/ejabberd/master/sql/pg.sql

curl -s https://raw.githubusercontent.com/processone/ejabberd/master/sql/pg.sql \
  -o ejabberd-psql-schema.sql
```

- Create Database. (eg. name ejabberd)
- Import the `ejabberd-psql-schema.sql` 

### Configure ejabberd to use PostgreSQL

To configure `ejabberd` to use database, we need to define in its configuration file.
By default, the configuration is not available, and, based on our structure of using
docker, if we mount the configuration, the folder of the configuration will be blank
and leads to service cannot startup as it cannot find its configuration file. To fix this
we need to copy the configuration folder from the docker image that we about
to deploy as the following.

```bash
echo "Seeding default ejabberd configuration into ${EJABBERD_CONF_PATH}..."
cid=$(docker create "${EJABBERD_IMAGE}")
docker cp "${cid}:/home/ejabberd/conf/." "${EJABBERD_CONF_PATH}/"
docker rm "${cid}"
```

After the configuration is created (`/var/data/ejabberd/conf/ejabberd.yml`), we need to
change the configuration to support the external database (PostgreSQL) as the following, 
the configuration option is global level, so add it after the `loglevel: info`:

```yml
loglevel: info

# Database Configuration
sql_type: pgsql
sql_server: ${EJABBERD_DB_HOST}
sql_port: ${EJABBERD_DB_PORT}
sql_database: ${EJABBERD_DB_NAME}
sql_username: ${EJABBERD_DB_USERNAME}
sql_password: ${EJABBERD_DB_PASSWORD}
default_db: sql
auth_method: sql
update_sql_schema: true
```

> [!NOTE]
> As the script already defined, we strongly recommend to run the existing script, as the 
> script will generate configuration file, initialize the database schema and migrate
> the database schema into the designated database server with defined database
> configuration information.
> 
> ```bash
> $> sudo ./init-config.sh
> $> sudo ./deploy.sh
> ```

## Development

Developing the Chat Client, we need to have ejabberd hosted on the local PC or hosted
in cloud with defined domain name. And, the configuration for chat client communicate
to the ejabberd server is based on where the ejabberd hosted. The following configuration
is to support the ejabberd host on local PC with `localhost` and alias domain name
defined in the `/etc/hosts` (eg `127.0.0.1 ejabberd.myservice.loc`) and hosted in the
cloud using the domain name (eg. `ejabberd.myservice.com`). The configuration uses
`webpack` (`webpack.conf.js`)

```js
const path = require('path');
const webpack = require('webpack');
const dotenv = require('dotenv');
const baseConfig = require('../../packages/web-config/webpack.config');
dotenv.config({ path: path.resolve(__dirname, '.env') });
const chatServerUrl = process.env.CHAT_SERVER_URL;

module.exports = (processor, conf) => {
  const config = baseConfig(processor, conf, {
    rules: {
      style: {
        use: ['style-loader', 'css-loader', 'postcss-loader'],
      },
    },
    copyPatterns: [
      {
        from: path.resolve('../../node_modules/@xmpp/client/dist/xmpp.min.js'),
        to: 'js/xmpp.min.js',
      },
      {
        from: path.resolve('./assets/js/upload.worker.js'),
        to: 'js/upload.worker.js',
      },
    ],
    htmlPlugin: {
      scriptLoading: 'blocking',
    },
  });

  config.resolve = {
    ...config.resolve,
    fallback: {
      ...(config.resolve?.fallback || {}),
      'node:dns': false,
      dns: false,
      net: false,
      tls: false,
    },
  };

  config.plugins = [
    ...(config.plugins || []),
    new webpack.IgnorePlugin({
      resourceRegExp: /^@xmpp\/(client|tcp|tls|resolve)$/,
    }),
  ];

  config.devServer = {
    ...(config.devServer || {}),
    webSocketServer: {
      type: 'ws',
      options: { path: '/wds' },
    },
    proxy: [
      {
        context: ['/ws'],
        target: chatServerUrl,        
        ws: true,
        changeOrigin: true,
        secure: false,
      },
      {
        context: ['/chat-upload'],
        target: chatServerUrl,
        pathRewrite: { '^/chat-upload': '/upload' },
        changeOrigin: true,
        secure: false,
        proxyTimeout: 600000,
      },
    ],
  };

  return config;
};
```

> [!NOTE]
> As Websocket requires secure connection, so to support the ejabberd hosted in
> the local PC, you need to define the proxy in context of `webpack.config.js` 
> need to points localhost site with TLS as the following:

```js
proxy: [
  {
    context: ['/ws'],
    target: 'https://ejabberd.myservice.loc:5443',
    pathRewrite: { '^/ws': '/websocket' },
    ws: true,
    changeOrigin: true,
    secure: false,
  },
  {
    context: ['/chat-upload'],
    target: 'https://ejabberd.myservice.loc:5443',
    pathRewrite: { '^/chat-upload': '/upload' },
    changeOrigin: true,
    secure: false,
    proxyTimeout: 600000,
  },
],
```
 
## Web Admin and HTTP API

Nginx (`nginx.conf`) publishes `http://ejabberd.localhost.com`. Two listeners in
`ejabberd.yml` sit behind it: plain HTTP on port `5280`, and TLS on port `5443`.
The stock image does not line those listeners up with the proxy, so `/admin`
login and `/api` fail until the parts below are edited by hand.

### Host header for `/admin`

On the `/admin` location, keep:

```nginx
proxy_set_header Host $host;
```

`$host` is the vhost, `ejabberd.localhost.com`. Webadmin uses that header as the
account domain when the username has no `@`. A fixed address such as
`172.18.0.1` makes a login of `admin` fail with `missing-server`.

Sign in as `admin`, or as `admin@ejabberd.localhost.com`. The password is
`EJABBERD_ADMIN_PASSWORD` in `.env`.

### Register `/api` on port 5280

`/api` is registered only on the TLS listener, port `5443`. Nginx sends
`/api` to port `5280`, and that listener has no API handler, so this URL
returns 404:

```text
http://ejabberd.localhost.com/api/registered_users?host=ejabberd.localhost.com
```

In `/var/data/ejabberd/conf/ejabberd.yml`, add `mod_http_api` to the plain HTTP
listener (`PORT_HTTP`, port `5280`):

```yaml
  -
    port: PORT_HTTP
    ip: "::"
    module: ejabberd_http
    request_handlers:
      /admin: ejabberd_web_admin
      /api: mod_http_api
      /.well-known/acme-challenge: ejabberd_acme
```

Leave the TLS listener as it is. It already serves `/api`.

### Let the admin account call the API through Nginx

The stock `api_permissions` block `"http access"` puts `acl: loopback` and
`acl: admin` in one `allow` list. Every entry in that list must match. Nginx
connects from the Docker network, not from `127.0.0.1`, so a correct admin
password still returns:

```json
{"code":32,"message":"AccessRules: Account does not have the right to perform the operation.","status":"error"}
```

In `"http access"`, leave a single `acl: admin` entry (and the same for the
OAuth rule). That allows the admin account from Nginx, with basic auth or an
`ejabberd:admin` token. Do not add a separate loopback rule: the stock file
never granted the full API to localhost by itself, and `"public commands"`
already allows `status` and `connected_users_number` from `127.0.0.1`.

```yaml
  "http access":
    from: mod_http_api
    who:
      access:
        allow:
          acl: admin
      oauth:
        scope: "ejabberd:admin"
        access:
          allow:
            acl: admin
    what:
      - "*"
      - "!stop"
      - "!start"
```

Reload after both edits:

```bash
sudo docker exec CONTAINER_ID ejabberdctl reload_config
```

`registered_users` is an admin command. Call it with the full admin JID:

```bash
curl -u "admin@ejabberd.localhost.com:${EJABBERD_ADMIN_PASSWORD}" \
  "http://ejabberd.localhost.com/api/registered_users?host=ejabberd.localhost.com"
```

### `host` must be a configured virtual host

Commands such as `check_account` and `registered_users` take a `host` field.
Ejabberd runs that command only when `host` is one of the names under `hosts:`.
The stock file lists the `HOST` macro, which becomes `EJABBERD_DOMAIN`
(`ejabberd.localhost.com`). Any other domain returns the same code 32, even
with a valid admin login:

```bash
curl -u "admin@ejabberd.localhost.com:${EJABBERD_ADMIN_PASSWORD}" \
  -H 'Content-Type: application/json' \
  -d '{"user":"85512337557","host":"ejabberd.localhost.com"}' \
  http://ejabberd.localhost.com/api/check_account
```

```json
{"code":32,"message":"AccessRules: Account does not have the right to perform the operation.","status":"error"}
```

The same call with `"host":"ejabberd.localhost.com"` succeeds. To keep using
another domain, add it next to `HOST` in `/var/data/ejabberd/conf/ejabberd.yml`
and reload:

```yaml
hosts:
  - HOST
  - ejabberd.localhost.com
```

```bash
sudo docker exec CONTAINER_ID ejabberdctl reload_config
```

## Enable HTTP Upload

To support file sharing and media transfers in ejabberd, you need to configure
HTTP File Upload (defined by XMPP standard XEP-0363).  This is done by
configuring two pieces in your, `ejabberd.yml` file: the listen port (to handle
the web traffic) and the `mod_http_upload` module (to handle the storage
and logical processing of files).

### Step 1: Enable the HTTP Upload Module

Under the `modules:` section of your `/etc/ejabberd/ejabberd.yml` configuration,
define the `mod_http_upload` settings:

```yaml
modules:
  mod_http_upload:
    docroot: "/var/lib/ejabberd/upload"
    put_url: "https://@HOST@:5443/upload"
    get_url: "https://@HOST@:5443/upload"
    max_size: 104857600 # Max file size in bytes (e.g., 100MB)
    custom_headers:
      "Access-Control-Allow-Origin": "*"
      "Access-Control-Allow-Methods": "GET, HEAD, PUT, OPTIONS"
      "Access-Control-Allow-Headers": "Content-Type"
```

### Step 2: Configure the Listener

Next, you need to verify that ejabberd is listening on port `5443` with TLS (HTTPS) enabled,
and that it routes HTTP upload requests to the module you just configured.
Look for the `listen:` block in your `ejabberd.yml` and add or modify
the `ejabberd_http` module entry:

```yaml
listen:
  - port: 5443
    ip: "::"
    module: ejabberd_http
    tls: true # false if you run it behind the proxy
    request_handlers:
      "/upload": mod_http_upload
```

> [!NOTE]
> If you have a reverse proxy like Nginx or Apache in front of ejabberd handling SSL/TLS
> termination, you can change `tls: true` to `tls: false` on port `5443` and let your proxy
> handle the HTTPS certificate).

To restart the service

```bash
# Access to the container
$> ejabberdctl reload_config

# or directly from host as:
$> sudo docker exec CONTAINER_ID ejabberdctl reload_config
```

> [!NOTE]
> How to generate the Admin Basic Auth Token to be used with API. You need to
> combine string of `${USER_NAME}@${VIRTAUL_HOST}:${PASSWORD}` can convert
> it into the `base64`. The following example is to create the Basic Auth token
> for `admin` user on the `ejabberd.localhost.com` with `admin@Secret1` password

```bash
$> echo -n "admin@ejabberd.localhost.com:admin@Secret1" | base64
```

## Add new Virtual Host

To add a new virtual host in ejabberd, you need to update your `ejabberd.yml` configuration file and restart the service. ejabberd allows you to host multiple virtual domains (e.g., `localhost`, `chat.example.com`, `domain2.com`) on a single server instance.

```yml
hosts
  - HOST
  - ejabberd.localhost.com
```

### Add new Admin to Virtual Host

```bash
$> ejabberdctl register admin ejabberd.localhost.com user_password
```