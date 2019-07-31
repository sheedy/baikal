FROM        nginx:latest
LABEL       maintainer  "Sheedy <git@michaelsheedy.com>"

# Set Environement variables
ENV         LC_ALL=C
ENV         DEBIAN_FRONTEND=noninteractive
ENV         BAIKAL_VERSION=0.5.3

# Update package repository and install packages

RUN         apt-get -y update && \
            apt-get -y install supervisor php7.3-fpm php7.3-sqlite3 wget unzip && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fetch the latest software version from the official repo if needed
RUN         test ! -d /usr/share/nginx/html/baikal && \
            wget https://github.com/sabre-io/Baikal/releases/download/${BAIKAL_VERSION}/baikal-${BAIKAL_VERSION}.zip && \
            unzip baikal-${BAIKAL_VERSION}.zip -d /usr/share/nginx/html && \
            chown -R www-data:www-data /usr/share/nginx/html/baikal && \
            rm baikal-${BAIKAL_VERSION}.zip
# RUN         touch /usr/share/nginx/html/baikal/Specific/ENABLE_INSTALL # for new installs

# Add configuration files. User can provides customs files using -v in the image startup command line.
COPY        supervisord.conf /etc/supervisor/supervisord.conf
COPY        nginx.conf /etc/nginx/nginx.conf
COPY        php-fpm.conf /etc/php7/fpm/php-fpm.conf

# Expose HTTP port
EXPOSE      80

# Last but least, unleach the daemon!
ENTRYPOINT  ["/usr/bin/supervisord"]
#CMD  ["/usr/bin/supervisord"]
