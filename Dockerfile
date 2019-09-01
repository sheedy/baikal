FROM        nginx:latest
LABEL       maintainer  "Sheedy <git@michaelsheedy.com>"

# RUN useradd -u 10001 -G www-data app
RUN groupadd -g 1001 app && \
    useradd -u 1001 -g app -G www-data -m app

# Set Environement variables
ENV         LC_ALL=C
ENV         DEBIAN_FRONTEND=noninteractive
ENV         BAIKAL_VERSION=0.5.3

# Update package repository and install packages

RUN         apt-get -y update && \
            apt-get -y install supervisor php7.3-fpm php7.3-sqlite3 php-xmlwriter php-dom php-mbstring wget unzip && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fetch the latest software version from the official repo if needed
RUN         test ! -d /usr/share/nginx/html/baikal && \
            wget https://github.com/sabre-io/Baikal/releases/download/${BAIKAL_VERSION}/baikal-${BAIKAL_VERSION}.zip && \
            unzip baikal-${BAIKAL_VERSION}.zip -d /usr/share/nginx/html && \
            chown -R www-data:www-data /usr/share/nginx/html/baikal && \
            rm baikal-${BAIKAL_VERSION}.zip

RUN         mkdir -p -m 755 \
            /var/run/supervisor \
            /var/run/php7.3-fpm \
            /var/log/supervisor \
            /var/log/apps \
            /run/php

RUN         touch /var/log/supervisor/supervisord.log \
            && touch /var/run/nginx.pid

RUN         chown -R app:app \
              /var/run/supervisor \
              /var/run/php7.3-fpm \
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
              /var/run/php7.3-fpm \
              /var/log/supervisor \
              /run/php \
              /var/log/apps \
              /var/cache/nginx

# RUN         touch /usr/share/nginx/html/baikal/Specific/ENABLE_INSTALL # for new installs

# Add configuration files. User can provides customs files using -v in the image startup command line.
COPY        --chown=app:app supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY        --chown=app:app nginx.conf /etc/nginx/nginx.conf
COPY        --chown=app:app php-fpm.conf /etc/php7.3/fpm/php-fpm.conf

USER app

# Expose HTTP port
EXPOSE      8080

# Last but least, unleach the daemon!
ENTRYPOINT  ["/usr/bin/supervisord"]
# CMD  ["/usr/bin/supervisord"]
