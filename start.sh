#!/bin/sh

# Загружает образы и запускает контейнеры

export $(egrep -v '^#' .env | xargs)

# Создание файла конфигурации Prometheus
if [ ! -f ./prometheus.yml ]; then
  cat > ./prometheus.yml <<EOL
global:
  scrape_interval:     15s  # определяет, как часто Prometheus будет собирать метрики с таргетов
  evaluation_interval: 15s  # определяет, как часто Prometheus будет оценивать правила (rules)

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

rule_files:  # файлы правил
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:  # определяет, какие ресурсы отслеживает Prometheus
  - job_name: 'prometheus'

    # Prometheus ожидает, что метрики будут доступны для таргетов по пути /metrics
    static_configs:
      - targets: ['127.0.0.1:9090']  # собирает данные о своём состоянии и производительности
  
  - job_name: 'dnscrypt'

    static_configs:
      - targets: ['${SERVER_IP}:9100']  # собирает данные DNSCrypt
EOL
fi

# Создание файла для настройки Prometheus в Grafana

if [ ! -f ./provisioning-prometheus.yml ]; then
  cat > ./provisioning-prometheus.yml <<EOL
apiVersion: 1

# список источников данных, которые следует удалить из базы данных
deleteDatasources:
  - name: Prometheus
    orgId: 1

# список источников данных для вставки/обновления в зависимости от того, что доступно в базе данных
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy  # режим доступа
    orgId: 1
    url: http://${SERVER_IP}:9090
    version: 1
    # позволяет пользователям редактировать источники данных из UI-интерфейса
    editable: true
EOL
fi

DNSCRYPT_EXISTS=$(docker ps -a | grep $DNSCRYPT_CONTAINER)
DNSCRYPT_RUNNING=$(docker ps -f status=running | grep $DNSCRYPT_CONTAINER)

if [ "$DNSCRYPT_EXISTS" = "" ]; then
  echo $(sudo docker run --name=$DNSCRYPT_CONTAINER \
    -p 443:443/udp -p 443:443/tcp -p 9100:9100 \
    --restart=unless-stopped \
    -v $(pwd)/volumes/dnscrypt/keys:/opt/encrypted-dns/etc/keys \
    -v $(pwd)/volumes/dnscrypt/unbound_zones:/opt/unbound/etc/unbound/zones \
    jedisct1/dnscrypt-server init -A -M 0.0.0.0:9100 -N $DNSCRYPT_DOMAIN -E $SERVER_IP:443) created
fi

if [ "$DNSCRYPT_RUNNING" = "" ]; then
  echo $(docker start $DNSCRYPT_CONTAINER) started
else
  echo "$DNSCRYPT_CONTAINER is running"
fi

echo ""
sudo docker-compose up
