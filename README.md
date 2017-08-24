Docker Nginx - PHP-FPM Image Builder
=======

Run ./build.sh to build your images. 

Parameters: 

 - `name:tag` the name and tag to use for the resulting docker image

Options:

 - `--env env` builds the image 
with configuration stored in config-{env} folder
 - `--php version` selects php version (builds from the {version}-fpm-alpine base).
 - `--customize dir` the name of the folder under `custom` to build from the resulting image. A Dockerfile should be present in `custom/{dir}`. See example folder for a starter template. By default all folders under custom will be built.

The script will automatically build your custom images by placing your Dockerfiles in the `custom` folder. Your image will have the name of the folder it is placed in, tagged with latest. E.g. for the example folder the image will be built as `example:latest`.

Example:

`./build.sh phpdevbase:latest --env dev --php 7.1.8 --customize phpdev`

Then you can start your container with the built image: 

`docker run -d -p 31287:80 --name dev-container phpdev:latest`

Available PHP versions:

 - 7.2-rc
 - 7.1 (default)
 - 7.0
 - 5.6

For a complete list see https://store.docker.com/images/php

