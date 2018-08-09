#!/usr/bin/env bash

# Example ssl domain on local machine with docker
# Please map ssldomain.local to 127.0.0.1 before running the script

# Start nginx proxy container
docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v /etc/nginx/certs \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
    jwilder/nginx-proxy

# Start nginx ssl companion container
docker run -d \
    --name nginx-ssl-companion \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --volumes-from nginx-proxy \
    jrcs/letsencrypt-nginx-proxy-companion

docker exec nginx-ssl-companion \
    openssl req -x509 \
    -newkey rsa:4096 \
    -sha256 \
    -nodes \
    -days 365 \
    -subj '/CN=ssldomain.local' \
    -keyout /etc/nginx/certs/ssldomain.local.key \
    -out /etc/nginx/certs/ssldomain.local.crt

docker exec nginx-proxy nginx -s reload 

# Start container listening on domain
docker run -d -e "VIRTUAL_HOST=ssldomain.local" --name nginx-ssl-test oak3docker/phpdev

# Test ssl connection
curl -s -D -k -v "https://ssldomain.local" -o /dev/null
