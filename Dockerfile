# https://github.com/ckulka/baikal-docker/blob/master/nginx.dockerfile

ARG FROM_ARCH=amd64

# Multi-stage build, see https://docs.docker.com/develop/develop-images/multistage-build/
FROM alpine AS builder

ENV VERSION 0.8.0

ADD https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip .
RUN apk add unzip && unzip -q baikal-${VERSION}.zip

# Final Docker image
FROM $FROM_ARCH/nginx:mainline

LABEL description="Baikal is a Cal and CardDAV server, based on sabre/dav, that includes an administrative interface for easy management."
LABEL version="0.8.0"
LABEL repository="https://github.com/sheedy/baikal"
LABEL website="http://sabre.io/baikal/"
LABEL maintainer  "Sheedy <git@michaelsheedy.com>"

RUN groupadd -g 1001 app && \
  useradd -u 1001 -g app -G app -m app

# Install dependencies: PHP & SQLite3
# RUN curl -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
#   echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list &&\
RUN echo "deb http://ftp.ca.debian.org/debian sid main" > /etc/apt/sources.list.d/php.list
RUN apt update
RUN apt install -y \
  php8.0-curl \
  php8.0-dom \
  php8.0-fpm \
  php8.0-mbstring \
  php8.0-mysql \
  php8.0-sqlite \
  php8.0-xmlwriter \
  sqlite3 \
  sendmail \
  supervisor \
  && rm -rf /var/lib/apt/lists/*

RUN usermod -aG nginx app
# Add Baikal & nginx configuration
COPY --from=builder baikal /var/www/baikal

RUN mkdir -p -m 755 \
  /var/run/supervisor \
  /var/run/php8.0-fpm \
  /var/log/supervisor \
  /var/log/apps \
  /run/php

RUN touch /var/log/supervisor/supervisord.log \
  && touch /var/run/nginx.pid

RUN chown -R app:app \
  /var/run/supervisor \
  /var/run/php8.0-fpm \
  /var/log/supervisor \
  /var/log/nginx \
  /var/log/apps \
  /run/php \
  /var/cache/nginx \
  /var/run/nginx.pid \
  && chmod u=rwx,go=rx,a+s /var/log/apps \
  && chmod -R g+w /var/cache/nginx \
  && chmod +x /home \
  && chmod +x /home/app \
  && chmod g+s \
  /var/run/supervisor \
  /var/run/php8.0-fpm \
  /var/log/supervisor \
  /run/php \
  /var/log/apps \
  /var/cache/nginx

RUN chown -R app:app /var/www/baikal
RUN mkdir -p -m 755 /var/log/baikal
RUN chown -R app:app /var/log/baikal
# RUN mkdir -p -m 755 /run/baikal/php && touch /run/baikal/php/php8.0-fpm.sock && chown -R app:app /run/baikal/php && chmod -R g+wx,go+x /run/baikal/php
# RUN chown -R app:app /run/php && chmod -R u+rwxs,g+rwxs /run/php
# RUN set -xe \
#   && mkdir -p /run/php \
# #   && touch /run/php/php8.0-fpm.sock \
#   && chown -R nginx:www-data /run

COPY --chown=app:app nginx.conf /etc/nginx/nginx.conf
COPY --chown=app:app php-fpm.conf /etc/php/8.0/fpm/pool.d/www.conf
COPY --chown=app:app supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /var/www/baikal/config
VOLUME /var/www/baikal/Specific

RUN chown -R app:app /var/www/baikal/Specific /var/www/baikal/config
RUN chown -R app:app /var/cache/nginx /etc/nginx/ /etc/php/

USER app

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT ["/usr/bin/supervisord"]
# RUN touch /var/www/baikal/baikal/Specific/ENABLE_INSTALL # for new installs

# CMD /etc/init.d/php8.0-fpm start && nginx

# sbin-path=/usr/sbin/nginx
# modules-path=/usr/lib/nginx/modules
# conf-path=/etc/nginx/nginx.conf
# error-log-path=/var/log/nginx/error.log
# http-log-path=/var/log/nginx/access.log
# pid-path=/var/run/nginx.pid
# lock-path=/var/run/nginx.lock
# http-client-body-temp-path=/var/cache/nginx/client_temp
# http-proxy-temp-path=/var/cache/nginx/proxy_temp
# http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp
# http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp
# http-scgi-temp-path=/var/cache/nginx/scgi_temp
