#!/bin/sh

# Удаляет контейнеры, но оставляет тома

sudo docker stop dnscrypt && sudo docker rm dnscrypt
sudo docker-compose down

rm prometheus.yml
rm provisioning-prometheus.yml

# удалить тома
# sudo docker-compose down -v
