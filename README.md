# wireguard-pihole-dnscrypt-docker

Скрипты для запуска в Docker контейнерах связки Wireguard VPN + Pihole + DNSCrypt Proxy  
В проекте используются Docker образы:

* [linuxserver/wireguard](https://hub.docker.com/r/linuxserver/wireguard) (требуется дистрибутив Linux на базе Ubuntu или Debian для запуска контейнера, иначе нужно устанавливать заголовки ядра вручную)
* [pihole/pihole](https://hub.docker.com/r/pihole/pihole)
* [gists/dnscrypt-proxy](https://hub.docker.com/r/gists/dnscrypt-proxy)

## Скрипты для работы с контейнерами

1. Запустить контейнеры: `./start.sh`
2. Остановить контейнеры: `./stop.sh`
3. Удалить контейнеры вместе с томами: `./delete.sh`

## Изменить настройки в файле .env

Поменять значение переменной среды `SERVER_IP` на свой IP  
Также можно поменять `TZ` на свою временную зону  
Заменить переменную `SUBNET` на свободную подсеть (проверить командой `ip addr | grep 172` утилиты `iproute2`) в формате: `172.x.0.` (без последнего нуля)  
Ещё можно поменять [маску подсети](https://ru.wikipedia.org/wiki/%D0%91%D0%B5%D1%81%D0%BA%D0%BB%D0%B0%D1%81%D1%81%D0%BE%D0%B2%D0%B0%D1%8F_%D0%B0%D0%B4%D1%80%D0%B5%D1%81%D0%B0%D1%86%D0%B8%D1%8F), задав целое число переменной `SUBNET_MASK` (например: 28)  
Если занят 8000 порт, изменить значение `PIHOLE_PORT` на любой свободный порт (проверить командой `sudo netstat -lntup`)  
Задать количество клиентов для WireGuard, изменив значение переменной `WIREGUARD_PEERS`  
Поменять при необходимости внутреннюю сеть Wireguard, изменив значение переменной `WIREGUARD_INTERNAL_SUBNET`  

## Настройка клиента Wireguard

1. Настроить клиент для смартфона по qr-коду: `./volumes/wireguard/config/peer1/peer1.png`
2. Настроить клиент для Linux на базе Ubuntu:
    * `sudo apt install wireguard`
    * `sudo apt install openresolv`
    * `sudo wg-quick up ./volumes/wireguard/config/peer2/peer2.conf` (для отключения использовать `wg-quick down peer2.conf`)

## Поменять временный пароль в Pihole

1. Запустить контейнеры в фоновом режиме: `docker-compose up -d`
2. Запустить pihole из контейнера с именем pihole и поменять пароль:  
   `docker exec -i pihole pihole -a -p NEW_PASSWORD`
3. Для проверки открыть в браузере `http://SERVER_IP:PIHOLE_PORT/admin`

## Настройка DNSCrypt Proxy

Изменить файл `./dnscrypt-proxy.toml`:

1. listen_addresses - изменить порт на тот, который указан в файле `.env` в переменной `DNSCRYPT_PORT`
2. server_names - одно из несколько имён DNSCrypt-серверов, которые перечислены [на официальном сайте DNSCrypt](https://dnscrypt.info/public-servers)
3. routes - server_name из предыдущего пункта и via ([анонимный DNS relay](https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/relays.md))

## Проверка Wireguard на сервере

Подключиться к Wireguard на клиенте  
Запустить `bash` внутри контейнера (`docker exec -it wireguard /bin/bash`) и выполнить следующие команды:

1. `wg` - проверить разрешённые ip и подключения к ним, например
    * allowed ips: `10.0.0.2/32`
    * latest handshake: 8 seconds ago
2. `ip -c addr` - проверить сетевые устройства
    * `wg0` с ip `10.0.0.1`
    * `eth0` с ip `172.20.0.2`
3. `ping -c 1 10.0.0.2` - пропинговать клиента peer1

## Проверка Wireguard на клиенте

1. Установить `dnsutils` в Linux или в `Termux` для Android
2. Выполнить такие же команды как на сервере: `wg`, `ip addr`, `ping -c 1 10.0.0.1`

## Проверка подключения Pihole к Wireguard на клиенте

1. Подключиться к Wireguard
2. Открыть Pihole в браузере `http://SERVER_IP:PIHOLE_PORT/admin`
3. Добавить какой-нибудь домен для блокировки в разделе `Blacklist`
4. Попробовать открыть домен из `Blacklist` в браузере - должен быть не доступен

## Проверка подключения DNSCrypt Proxy на клиенте

1. Установить `dnsutils` в Linux или в `Termux` для Android
2. Подключиться к Wireguard
3. Выполнить команду `dig google.com` (в строке SERVER должен быть указан 10.0.0.1)

## [Списки блокировок](block_white_lists.md)
