#Arguments
ARG BUILD_FROM=test

FROM $BUILD_FROM

# Generate image ssh key
# Images with a key pair should not be pushed to public repositories.
RUN rm -rf /root/.ssh/base_id_rsa* \
	&& ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

#Start your customizations here

#Example 

#install postgresql and zip support
RUN set -ex \
	&& apk --no-cache add postgresql-dev \
	&& docker-php-ext-install pdo pdo_pgsql zip

#Expose port 80
EXPOSE 80
