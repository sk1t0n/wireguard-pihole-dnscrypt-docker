#!/bin/sh

# Удаление контейнеров вместе с томами
sudo docker-compose down -v
sudo rm -rf volumes
sudo rm Corefile
