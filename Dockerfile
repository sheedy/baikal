ARG FROM_ARCH=amd64

# Multi-stage build, see https://docs.docker.com/develop/develop-images/multistage-build/
FROM alpine AS builder

ENV VERSION 0.8.0

ADD "https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip" .
RUN apk add unzip && unzip -q baikal-${VERSION}.zip

# Final Docker image
FROM $FROM_ARCH/nginx:mainline

LABEL description="Baikal is a Cal and CardDAV server, based on sabre/dav, that includes an administrative interface for easy management."
LABEL version="0.8.0"
LABEL repository="https://github.com/sheedy/baikal"
LABEL website="http://sabre.io/baikal/"
LABEL maintainer  "Sheedy <git@michaelsheedy.com>"

# Add non-root user
RUN groupadd -g 1001 app && \
  useradd -u 1001 -g app -G app -m app

# Install dependencies: PHP & SQLite3
RUN curl -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
  echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list &&\
  apt update && \
  apt install -y \
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

# Add Baikal
COPY --from=builder baikal /var/www

# Create directories
RUN mkdir -p -m 755 /run/app /var/log/app /var/tmp

# Set permissions
RUN chown -R app:app \
  /var/tmp \
  /var/www \
  /var/log/app \
  /var/cache/nginx \
  /run/app

# Copy config files
COPY --chown=app:app nginx.conf /etc/nginx/nginx.conf
COPY --chown=app:app php-fpm.conf /etc/php/8.0/fpm/pool.d/www.conf
COPY --chown=app:app supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=app:app entrypoint.sh /entrypoint.sh

# Set non-root user
USER app

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
