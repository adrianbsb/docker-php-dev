#!/usr/bin/env bash

### Remove base image ssh key
if [ -f "/root/.ssh/base_id_rsa" ] ; 
then 
	rm -rf /root/.ssh/base_id_rsa* 
fi

### Retrieve public ssh key (id_rsa.pub)
if [ -f "/root/.ssh/id_rsa.pub" ] ;
then
	cp /root/.ssh/id_rsa.pub /var/local/id_rsa.pub
	chown www-data /var/local/id_rsa.pub
fi	 

### Set web server root folder according to env variable ###

NGINX_HOST_TPL_FILE=/etc/nginx/sites-available/template.conf
NGINX_HOST_CFG_FILE=/etc/nginx/sites-available/active.conf

if [ -n "$SERVER_ROOT" ] ;
then
	echo "Server root set to ${SERVER_ROOT} ..."
	echo "$SERVER_ROOT" >> /tmp/SERVER_ROOT
else
	echo "Server root set to /var/www ..."
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
  echo "Initializing app ... "	
  bash /var/www/init.sh
else
	
	if [ ! -f "${SERVER_ROOT}/index.php" ] ;
	then 	
		
		#Copy welcome file to index
		cp /tmp/welcome.php "${SERVER_ROOT}/index.php"
		
	fi
	
fi

echo "All done, starting services ..."
