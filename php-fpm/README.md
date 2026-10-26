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
