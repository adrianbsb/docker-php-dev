#Arguments
ARG BUILD_FROM=test

FROM $BUILD_FROM

# Generate image ssh key
# Images with a key pair should not be pushed to public repositories.
RUN rm -rf /root/.ssh/base_id_rsa* \
	&& ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
	
# Install Memcached extension
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

RUN apk add --no-cache --update libmemcached-libs zlib libzip libzip-dev \
    curl-dev libxml2-dev libedit-dev libsodium-dev tidyhtml-dev postgresql-dev

RUN set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
    && pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
    && rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps

#Install ICU support
RUN set -xe \
    && apk add --update icu \
    && apk add --no-cache --virtual .php-deps make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS zlib-dev icu-dev g++ pcre-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl

# Install Redis extension
RUN docker-php-source extract && \
    pecl install xdebug redis && \
    docker-php-ext-enable xdebug redis && \
    docker-php-source delete

# Install php extensions
RUN set -ex \
	&& pecl install igbinary zip \
	&& docker-php-ext-enable igbinary zip \
	&& docker-php-ext-install pdo bcmath curl intl pdo_mysql pdo_pgsql soap xml xmlrpc json readline \
	sodium calendar simplexml tidy xmlrpc \
	&& CFLAGS="-I/usr/src/php" docker-php-ext-install xmlreader

# Expose port 80
EXPOSE 80
