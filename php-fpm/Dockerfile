FROM php:8.3.36-fpm-alpine3.23

# mbstring, curl, and pdo are already compiled into the official image.
# pdo_pgsql and pgsql need libpq; gd needs libpng, freetype, jpeg, and webp.
# zip is the PHP extension; the zip and unzip packages are the CLI tools.
RUN apk add --no-cache \
  curl \
  freetype \
  libjpeg-turbo \
  libpng libwebp libpq libzip \
  supervisor \
  zip unzip \

  && apk add --no-cache --virtual .build-deps \
  freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev \
  libzip-dev \
  postgresql-dev \

  && docker-php-source extract \
  && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j"$(nproc)" \
    exif pcntl bcmath gd pdo_pgsql pgsql zip \

  && docker-php-source delete \
  && apk del .build-deps \

  && mkdir -p /etc/supervisor.d \
  && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY ./php/conf.d/zz-app.ini "$PHP_INI_DIR/conf.d/zz-app.ini"
COPY ./supervisord.conf /etc/supervisord.conf
COPY ./supervisor.d/worker.ini /etc/supervisor.d/worker.ini
COPY ./worker-entrypoint.sh /usr/local/bin/worker-entrypoint
RUN chmod +x /usr/local/bin/worker-entrypoint

WORKDIR /var/www

# php-fpm and the background worker are both children of supervisord.
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
