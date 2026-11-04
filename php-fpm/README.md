# PHP-FPM

Deploy PHP-FPM docker based is have it's static resource mounted along-side with NGINX, and
PHP-FPM decker to handle the PHP Script (for more information refers to `nginx.conf`
configuration file).

## Keynotes

- Mount static to /var/www/public
- Proxy the PHP Script to PHP-FPM container

## PHP Source and Extension

docker-php-source is a helper script that ships with the official PHP images
(php:8.3-fpm-alpine and the rest). It unpacks and removes the PHP source tree that those
images keep compressed so you can compile extensions.

The image stores PHP’s source as `/usr/src/php.tar.xz`. Compiling an extension needs the
unpacked tree at `/usr/src/php`. The script has two commands:

- `docker-php-source` extract unpacks that archive into `/usr/src/php`.
- `docker-php-source delete` removes `/usr/src/php`. The `.tar.xz` stays, so a later build can extract it again.

`docker-php-ext-install` and `docker-php-ext-configure` compile against that tree.
extract runs first so the build can see the headers.  delete runs in the same RUN so
the unpacked tree (tens of megabytes) is not left in the image layer. The compressed archive
is small and is kept on purpose.

```dockerfile
&& docker-php-source extract \
&& docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
&& docker-php-ext-install -j"$(nproc)" \
  exif pcntl bcmath gd pdo_pgsql pgsql \
&& docker-php-source delete \
```

## Build and Deploy

How it works, the request is handled by Nginx and Nginx forward the request to PHP-FPM to execute
the requested script file. So, we need to make sure the project folder is mounted at the nginx
and PHP-FPM service.

After the service up and running, you need get into the container and change the permission
as the following:

```bash
$> sudo docker exec -it CONTAINER_ID sh
$> chown -R www-data:www-data storage bootstrap/cache
$> chmod -R 755 storage bootstrap/cache
```

## Check List

- Make sure the certificate is correct if you need to have sign certificate
- Make sure the `APP_KEY` in the .env is set correctly.
