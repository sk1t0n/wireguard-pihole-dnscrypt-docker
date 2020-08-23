#!/bin/sh

# Загружает образы и запускает контейнеры

export $(egrep -v '^#' .env | xargs)

DNSCRYPT_EXISTS=$(docker ps -a | grep $DNSCRYPT_CONTAINER)
DNSCRYPT_RUNNING=$(docker ps -f status=running | grep $DNSCRYPT_CONTAINER)

if [ "$DNSCRYPT_EXISTS" = "" ]; then
    echo $(docker run --name=$DNSCRYPT_CONTAINER -p 443:443/udp -p 443:443/tcp \
        --restart=unless-stopped \
        -v $(pwd)/volumes/dnscrypt/keys:/opt/encrypted-dns/etc/keys \
        -v $(pwd)/volumes/dnscrypt/unbound_zones:/opt/unbound/etc/unbound/zones \
        jedisct1/dnscrypt-server init -N $DNSCRYPT_DOMAIN -E $SERVER_IP:443) created
fi

if [ "$DNSCRYPT_RUNNING" = "" ]; then
    echo $(docker start $DNSCRYPT_CONTAINER) started
else
    echo "$DNSCRYPT_CONTAINER is running"
fi

echo ""
docker-compose up
