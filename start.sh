#!/bin/sh


# Добавляет переменные среды из .env-файла
export $(egrep -v '^#' .env | xargs)

# Создаёт файл конфигурации DNS для Wireguard
if [ ! -f ./Corefile ]; then
  cat > ./Corefile <<EOL
. {
    forward . ${SUBNET}3
}
EOL
fi

# Загружает образы и запускает контейнеры
docker-compose up
