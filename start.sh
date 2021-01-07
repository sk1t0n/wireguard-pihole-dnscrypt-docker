#!/bin/sh

# Добавление переменных среды из .env-файла
export $(egrep -v '^#' .env | xargs)

# Создание файла конфигурации DNS для Wireguard
if [ ! -f ./Corefile ]; then
  cat > ./Corefile <<EOL
. {
    forward . ${SUBNET}3
}
EOL
fi

# Загрузка образов и запуск контейнеров
sudo docker-compose up -d
