####Docker Nginx-PHP-FPM Image Builder

Run ./build.sh to build/update your images. 

Parameters: 

 - `name:tag` the name and tag to use for the resultimn docker image

Options:

 - `--env` builds the image 
with configuration stored in config-{env} folder
 - `--php` selects php version (builds from the {version}-fpm-alpine base).

Example:

`./build.sh devimage:latest --env dev --php 7.1.8`

Then you can base your containers on the new built image: 

`docker run -d -p 31287:80 --name dev-container devimage:latest`

Or base your images on it (Dockerfile):

    FROM devimage:latest
    
    ENV SERVER_ROOT /var/www/public
    ENV APP_ENV dev
    
    EXPOSE 80

Available PHP versions: 

 - 7.2.0beta2
 - 7.1.8 (default)
 - 7.0.22
 - 5.6.31

For a complete list see https://store.docker.com/images/php

