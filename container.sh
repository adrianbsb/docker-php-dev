#!/usr/bin/env bash

### Set web server root folder according to env variable ###

NGINX_HOST_TPL_FILE=/etc/nginx/sites-available/template.conf
NGINX_HOST_CFG_FILE=/etc/nginx/sites-available/active.conf

PHP_VERSION=$(php -v | grep --only-matching --perl-regexp "\\d\.\\d+\.\\d+" | head -n 1)
PHP_MAJOR_VERSION=${PHP_VERSION:0:3}

if [ -n "$SERVER_ROOT" ] ;
then
	echo "$SERVER_ROOT" >> /tmp/SERVER_ROOT
else
	SERVER_ROOT=/var/www
fi

if [ -f $NGINX_HOST_CFG_FILE ] ;
then
	#remove previous config file
	rm $NGINX_HOST_CFG_FILE
fi

PHP_COMMAND="echo str_replace('root	__ROOTDIR__', 'root	$SERVER_ROOT', file_get_contents('$NGINX_HOST_TPL_FILE'));"
php -r "$PHP_COMMAND" >> /tmp/temporary.conf
mv -f /tmp/temporary.conf $NGINX_HOST_CFG_FILE

mkdir /etc/nginx/sites-enabled
rm /etc/nginx/sites-enabled/active
ln -s /etc/nginx/sites-available/active.conf /etc/nginx/sites-enabled/active


### Append Container variables to PHP-FPM pool configuration ###

FPM_POOL_CFG_FILE=/usr/local/etc/php-fpm.d/www.conf

echo "" >> $FPM_POOL_CFG_FILE;
echo ";container environment variables" >> $FPM_POOL_CFG_FILE;

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for i in $(env)
do

  variable=$(echo "$i" | cut -d'=' -f1)
  value=$(echo "$i" | cut -d'=' -f2)

  if [ -z "$value" ] || [ -z "$variable" ] ; 
  then 
	  #Ignore empty vars
	  continue;
  fi	  	  	

  if [[ $variable == ENV_* ]] || [[ $variable == AWS_* ]] || [[ $variable == APP_* ]] || [[ $variable == RDS_* ]] || [[ $variable == PHP_* ]] ;
  then
	#Append variable to PHP pool config file
  	echo "env[$variable] = \"$value\"" >> $FPM_POOL_CFG_FILE;
  fi

done

IFS=$SAVEIFS

### Run composer install & app bootstrap scripts ###
cd /var/www

touch .env

#Run composer install
if [ -f "/var/www/composer.json" ] ;
then

	if [ -n "$APP_ENV" ] ;
	then

    	if [ "$APP_ENV" = 'dev' ] ;
    	then
        	composer install
    	fi

    	if [ "$APP_ENV" = 'test' ] ;
    	then
        	composer install
    	fi

    	if [ "$APP_ENV" = 'staging' ] ;
    	then
        	composer install --no-dev
    	fi

    	if [ "$APP_ENV" = 'production' ] ;
    	then
        	composer install --no-dev
    	fi

	else
    	composer install --no-dev
	fi

fi

#Run app init script
if [ -f "/var/www/init.sh" ] ;
then
  bash /var/www/init.sh
else
	#Download readme to /var/www
	echo "<?php phpinfo();" >> /var/www/index.php
fi
