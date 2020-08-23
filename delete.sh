#!/bin/sh

# Удаляет контейнеры, но оставляет тома

docker stop dnscrypt && docker rm dnscrypt
docker-compose down

# удалить тома
# sudo rm -rf volumes
