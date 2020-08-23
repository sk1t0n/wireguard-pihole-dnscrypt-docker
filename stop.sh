#!/bin/sh

# Останавливает контейнеры

export $(egrep -v '^#' .env | xargs)

DNSCRYPT_RUNNING=$(docker ps -f status=running | grep $DNSCRYPT_CONTAINER)

if [ "$DNSCRYPT_RUNNING" != "" ]; then
    echo $(docker stop $DNSCRYPT_CONTAINER) stopped
else
    echo "$DNSCRYPT_CONTAINER not started"
fi

echo ""
docker-compose down
