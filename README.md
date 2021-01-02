# wireguard-pihole-dnscrypt-docker

Скрипты для запуска в Docker контейнерах связки Wireguard VPN + Pihole + DNSCrypt  
В проекте используются Docker образы:

* [linuxserver/wireguard](https://hub.docker.com/r/linuxserver/wireguard)
* [pihole/pihole](https://hub.docker.com/r/pihole/pihole)
* [jedisct1/dnscrypt-server](https://hub.docker.com/r/jedisct1/dnscrypt-server)

## Скрипты для работы с контейнерами

1. Запустить контейнеры: `./start.sh`
2. Остановить контейнеры: `./stop.sh`
3. Удалить контейнеры: `./delete.sh` (удалить тома: `sudo rm -rf volumes`)

## Поменять временный пароль в Pihole

1. Запустить контейнеры в фоновом режиме: `docker-compose up -d`
2. Запустить pihole из контейнера с именем pihole и поменять пароль:  
   `docker exec -i pihole pihole -a -p NEW_PASSWORD`

## Изменить настройки в файле .env

Поменять значение переменной среды `SERVER_IP` на свой IP  
Также можно поменять `TZ` на свою временную зону  
Заменить переменную `SUBNET` на свободную подсеть (проверить командой `ip -c addr | grep 172` утилиты `iproute2`) в формате: `172.x.0.` (без последнего нуля)  
Ещё можно поменять [маску подсети](https://ru.wikipedia.org/wiki/%D0%91%D0%B5%D1%81%D0%BA%D0%BB%D0%B0%D1%81%D1%81%D0%BE%D0%B2%D0%B0%D1%8F_%D0%B0%D0%B4%D1%80%D0%B5%D1%81%D0%B0%D1%86%D0%B8%D1%8F), задав целое число переменной `SUBNET_MASK` (например: 28)  
Если занят 8000 порт, изменить значение `PIHOLE_PORT` на любой свободный порт (проверить командой `sudo netstat -lntup`)  
При желании поменять доменные имена `DNSCRYPT_DOMAIN` и `PIHOLE_DOMAIN`  
Задать количество клиентов для WireGuard, изменив значение переменной `WIREGUARD_PEERS`  
Поменять при необходимости внутреннюю сеть Wireguard, изменив значение переменной `WIREGUARD_INTERNAL_SUBNET`  
Также можно поменять имя пользователя и пароль для Grafana: `GRAFANA_ADMIN_USER`, `GRAFANA_ADMIN_PASSWORD`

## Настройка DNS в Wireguard

Создать тома, запустив контейнеры командой `./start.sh`  
Изменить файл `./volumes/wireguard/config/coredns/Corefile` по примеру (заменить 20 на свою подсеть)

    . {
        loop
        forward . 172.20.0.3
    }

## Настройка клиента Wireguard

Настроить клиент для смартфона (по qr-коду) или компьютера, используя настройки из папки `./volumes/wireguard/config/peer1/` (клиент2 - peer2 и т.д.)

## Настройка Unbound (если необходимо)

1. Создать файл .conf: `touch ./volumes/dnscrypt/unbound_zones/example.conf`
2. Добавить одну или несколько несвязанных директив

Пример:

      local-zone: "example.com." static
      local-data: "my-computer.example.com. IN A 10.0.0.1"
      local-data: "other-computer.example.com. IN A 10.0.0.2"

## Проверка подключения Wireguard на сервере

Подключиться к Wireguard на клиенте  
Запустить `bash` внутри контейнера (`docker exec -it wireguard /bin/bash`) и выполнить следующие команды:

1. `wg` - проверить разрешённые ip и подключения к ним, например
    * allowed ips: `10.0.0.2/32`
    * latest handshake: 8 seconds ago
2. `ip -c addr` - проверить сетевые устройства
    * `wg0` с ip `10.0.0.1`
    * `eth0` с ip `172.20.0.2`
3. `ping -c 1 10.0.0.2` - пропинговать клиента peer1

## Проверка подключения Pihole на клиенте

1. Подключиться к Wireguard
2. Проверить в браузере `172.20.0.3` - должен быть доступен
3. Отключиться от Wireguard
4. Проверить в браузере `172.20.0.3` - должен быть не доступен

## Проверка подключения DNSCrypt на клиенте

1. Установить `dnsutils` в Linux или в `Termux` для Android
2. Выполнить команду `dig google.com -p 53 @SERVER_IP`
