#!/bin/bash

# Baikal can't write the `db` folder so we hav to create it
# ... or you could just create it in the folder you're mounting in the `volumes`
mkdir -p /var/www/Specific/db
# `chown` the newly created directory
chown -R app:app /var/www/Specific

# Run supervisor
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
