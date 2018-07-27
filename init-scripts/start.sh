#!/bin/bash

### Initialize container ###
if [ ! -f __initialized ] ;
then

    # Remove default host config
    rm /etc/nginx/conf.d/default.conf

    CTIME=`date +"%F %T"`
    echo  "$CTIME" >> __initialized

	# Execute container script
    bash /home/bin/container

fi


# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf