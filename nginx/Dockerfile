FROM nginx:stable-alpine

MAINTAINER Etienne Dauvergne <contact@ekyna.com>

ARG gid
ARG uid

ENV TZ="Europe/Paris"

RUN apk --no-cache add shadow \
 && groupmod -g $gid www-data \
 && adduser -D -u $uid -h /var/www -s /bin/bash -G www-data www-data \
 && mkdir -p /var/www/symfony/public \
 && chmod -Rf 755 /var/www/symfony \
 && chown -Rf www-data:www-data /var/www \
 && if [[ -n ${TZ} ]] && [[ -f /usr/share/zoneinfo/${TZ} ]]; then cp /usr/share/zoneinfo/${TZ} /etc/localtime; echo ${TZ} > /etc/timezone; fi

WORKDIR /var/www
