#!/bin/sh

# удаляет контейнеры вместе с томами
docker-compose down -v
sudo rm -rf volumes
sudo rm Corefile
