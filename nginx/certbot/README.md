# Harbor

## Pre-Installation

To use harbor properly, we should not run harbor behind free Cloudflare service as it
limits the size of 100Mb upload and download. To support the bigger size of the image,
we need to use the edge Nginx with own SSL (using Let's encrypt). The following command is to generate SSL for domain we are about to assign to harbor (`registry.mydomain.com`).

### Bring Domain up 
To challenge this, we need to face a challenging for Nginx that already running in the
production mode. To make it work, we need to set up new site to support the path
which will be reached by Let's Encrypt (`.well-known/acme-challenge`) as the 
following:

```nginx
server {
  listen 80;
  server_name registry.mydomain.com;

  location ~/.well-known/acme-challenge/ {
    root /usr/share/nginx/html;
    allow all;
  }

  location / {
    root /usr/share/nginx/html/;
    index  index.html;
  }
}
```

### Generate Certificate

Because the Nginx configuration file references Let's Encrypt paths that don't exist yet,
you should generate your free certificates before starting Nginx to prevent it from crashing
on boot. Run Certbot standalone to fetch your keys (ensure your Cloudflare domain is set
to DNS Only / Grey Cloud so Let's Encrypt can see your server):

```bash
$> docker run --rm -it \
  -p 8082:80 \
  -v "$(pwd)/certs:/etc/letsencrypt" \
  -v "common_webroot:/webroot" \
  certbot/certbot certonly --webroot \
  -w /webroot \
  -d registry.mydomain.com
```

> [!NOTE]
> Please note that, generating certificate using `webroot` so the Nginx configuration
> need to mount the `webroot` volume which will be seen by Nginx and Certbot.
> So, the following example is to deploy Nginx with `webroot` volume:

```yml
networks:
  backend:
    driver: overlay
volumes:
  nginx-cache:
  webroot:

services:
  nginx:
    image: nginx:latest
    networks:
      - backend
    deploy:
      mode: replicated
      replicas: 1
    ports:
      - "${HOST_HTTP_PORT}:80"
      - "${HOST_HTTPS_PORT}:443"
    volumes:
      - ./ssl/:/etc/nginx/ssl
      - nginx-cache:/var/www:cached
      - webroot:/usr/share/nginx/html
      - ${LOG_PATH}:/var/log/nginx
      - ${CONF_PATH}/sites:/etc/nginx/sites
      - ${CONF_PATH}/conf.d:/etc/nginx/conf.d
      - ${CONF_PATH}/certs:/etc/nginx/certs:ro
```

### Bring the website up

To bring