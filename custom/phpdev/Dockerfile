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

# Install sshd
RUN apk --update add --no-cache openssh bash \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd \
  && rm -rf /var/cache/apk/*
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

# Expose port 80
EXPOSE 80

# Expose port 22
EXPOSE 22
