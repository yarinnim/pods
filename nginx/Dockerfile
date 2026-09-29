FROM nginx:alpine

RUN apk update && apk upgrade \
  && apk --update add logrotate openssl bash curl

RUN set -x ; \
    addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

# Create 'messages' file used from 'logrotate'
RUN touch /var/log/messages

# Copy 'logrotate' config file
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./sites/README.md /etc/nginx/README.md
COPY logrotate/nginx /etc/logrotate.d/

# Set upstream conf and remove the default conf
RUN rm /etc/nginx/conf.d/default.conf

ADD ./startup.sh /opt/startup.sh
RUN sed -i 's/\r//g' /opt/startup.sh
CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 80 81 443
