#!/bin/bash

# check if folder wordpress exists
if [ ! -d "/config/wordpress" ]; then
    echo "Wordpress folder not found. Creating..."
    # copy wordpress folder
    cp -r /defaults/wordpress /config/
    echo "Wordpress folder created."
else
    echo "Wordpress folder exists"
fi

# fix perms
chown -R www-data /config/wordpress

# start apache
echo "Starting apache"
/usr/sbin/apache2ctl -D FOREGROUND
