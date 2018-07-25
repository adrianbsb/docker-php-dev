# Arguments for stage one
ARG BUILD_VERSION=7

# Pull php:$version-fpm-alpine (https://store.docker.com/images/php)
FROM php:$BUILD_VERSION-fpm-alpine

# Mantainer info
MAINTAINER Adrian7 <adrian.silimon@yahoo.com>

# Arguments for stage two
ARG BUILD_CONFIG=dev

# Install

RUN apk --no-cache add libmcrypt-dev autoconf gcc freetype libpng libjpeg-turbo freetype-dev libpng-dev \
        libjpeg-turbo-dev make libc-dev pcre-dev \
        wget git openssh nginx ca-certificates supervisor bash \
	&& pecl install mcrypt-1.0.1 xdebug \
	&& docker-php-ext-enable mcrypt xdebug \
    && docker-php-ext-install mbstring mysqli pdo_mysql opcache \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /var/www \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && composer global require "hirak/prestissimo:^0.3" 
	
#Configure

RUN ssh-keygen -f /root/.ssh/base_id_rsa -t rsa -N ''

COPY ./config-${BUILD_CONFIG}/nginx/host.conf /etc/nginx/sites-available/template.conf
COPY ./config-${BUILD_CONFIG}/nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./config-${BUILD_CONFIG}/php/php.ini /usr/local/etc/php/php.ini
COPY ./config-${BUILD_CONFIG}/php/conf.d /usr/local/etc/php/conf.d

COPY ./config-${BUILD_CONFIG}/fpm/fpm.conf /usr/local/etc/php-fpm.conf
COPY ./config-${BUILD_CONFIG}/fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY ./config-${BUILD_CONFIG}/supervisord.conf /etc/supervisord.conf

COPY ./init-scripts/container.sh /home/bin/container
COPY ./init-scripts/start.sh /start.sh
COPY ./init-scripts/welcome.php /home/welcome.php

ENV PHP_BUILD_CONFIG=$BUILD_CONFIG

#Set working directory
WORKDIR /

#Set volumes

VOLUME /var/www

#Entrypoint

CMD ["/bin/bash", "/start.sh"]	