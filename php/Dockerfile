FROM ekyna/php7-fpm-dev:7.4.16

MAINTAINER Etienne Dauvergne <contact@ekyna.com>

ARG uid
ARG gid

ENV TZ="Europe/Paris"

COPY php-fpm.conf    /usr/local/etc/php-fpm.d/zz-www.conf
COPY php.ini         /usr/local/etc/php/php.ini

WORKDIR /var/www

RUN apk --no-cache add shadow \
 && groupmod -g $gid www-data \
 && usermod -u $uid www-data \
 && chown -Rf www-data:www-data /var/www \
 && if [[ -n ${TZ} ]] && [[ -f /usr/share/zoneinfo/${TZ} ]]; then cp /usr/share/zoneinfo/${TZ} /etc/localtime; echo ${TZ} > /etc/timezone; fi

USER www-data:www-data
