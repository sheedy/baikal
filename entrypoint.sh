#!/bin/bash
# ls -lha /var/run
# ls -lha /var/cache
# ls -lha /home/app
echo "I am $(id -u)"
id
# echo "looking for supervisor"
# supervisord -h
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
# exec /usr/sbin/nginx -c /etc/nginx/nginx.conf
