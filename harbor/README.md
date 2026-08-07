# Harbor
Because Harbor is an enterprise-grade container registry made up of multiple
tightly integrated components (Registry, Core, Portal, Database, Redis, Trivy,
Jobservice), *running Harbor does not work with a single standalone
`docker-compose.yml` file written by hand*.

Harbor uses an official installer package that generates a complete, multi-container
`docker-compose.yml` tuned specifically for your server's storage paths,
security settings, and networking. Here is the quick, production-ready way
to generate and bring up Harbor.

## Installation

### Step 1: Download the Official Harbor Offline Installer

```bash
HARBOR_VERSION="2.15.2"
wget https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz

# Extract the archive
tar xvf harbor-offline-installer-v${HARBOR_VERSION}.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml
```

### Step 2: Configure

Open `harbor.yml` in a text editor. If you are placing Harbor behind a reverse proxy
(like Nginx, Traefik, or Caddy) to handle your domain's SSL, set it up as a plain
HTTP service. The following configuration is to set up the using HTTP protocol, 
external PostgreSQL and external Redis server:

```yml
# Set your domain or IP address
hostname: harbor.yourdomain.com

# HTTP configuration
http:
  port: 80

# IMPORTANT: Comment out or delete the 'https:' section below 
# if your external reverse proxy / Nginx handles SSL certificates.
# https:
#   port: 443
#   certificate: /your/cert/path.crt
#   private_key: /your/key/path.key

# Set your admin password for the Harbor UI
harbor_admin_password: YourStrongPassword123!

# Storage location for Docker images
data_volume: /data

external_database:
  harbor:
    host: common_postgresql
    port: 5432
    db_name: registry
    username: admin
    password: admin@Secret1
    ssl_mode: disable
    max_idle_conns: 2
    max_open_conns: 0


external_redis:
  host: common_redis:6379
  password: admin@Secret1
  tlsOptions:
    enable: false
    rootCA:
  registry_db_index: 1
  jobservice_db_index: 2
  trivy_db_index: 5
  idle_timeout_seconds: 30
```
