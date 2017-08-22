#Pull php:7-fpm-alpine (https://store.docker.com/images/php)
FROM php:7-fpm-alpine

MAINTAINER Adrian7 <adrian.silimon@yahoo.com>

#Arguments
ARG BUILD_CONFIG=dev

#Install

RUN apk --no-cache add \
        libmcrypt-dev \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
        wget \
        git \
        nginx \
        ca-certificates \
        supervisor \
        bash \
    && docker-php-ext-install \
        mcrypt \
        mbstring \
        mysqli \
        pdo_mysql \
        opcache \
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

COPY ./config-${BUILD_CONFIG}/nginx-host-template.conf /etc/nginx/sites-available/template.conf
COPY ./config-${BUILD_CONFIG}/nginx.conf /etc/nginx/nginx.conf
COPY ./config-${BUILD_CONFIG}/php.ini /usr/local/etc/php/php.ini
COPY ./config-${BUILD_CONFIG}/supervisord.conf /etc/supervisord.conf

COPY ./container.sh /home/bin/container
COPY ./start.sh /start.sh

#Set volumes

VOLUME /var/www

#Entrypoint

CMD ["/bin/bash", "/start.sh"]	