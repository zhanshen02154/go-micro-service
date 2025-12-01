#!/bin/bash

groupadd kafka
useradd -s /sbin/nologin -g kafka kafka

SERVERUUID=$(bin/kafka-storage.sh random-uuid)
bin/kafka-storage.sh format -t $SERVERUUID -c config/kraft/server.properties 

cat > /lib/systemd/system/kafka.service <<EOF
[Unit]
Description=Apache Kafka Server

[Service]
Type=forking
User=kafka
Group=kafka
Environment="JAVA_HOME="
ExecStart=/home/kafka/kafka_2.12-3.0.1/bin/kafka-server-start.sh daemon /home/kafka/kafka_2.12-3.0.1/config/kraft/server.properties
ExecStop=/home/kafka/kafka_2.12-3.0.1/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF