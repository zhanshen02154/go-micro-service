#!/bin/bash

mkdir -p /dev-data/consul-1.7.3
mkdir /dev-data/consul-1.7.3/data
mkdir /dev-data/consul-1.7.3/conf
mkdir /dev-data/consul-1.7.3/logs
cat > /dev-data/consul-1.7.3/conf/consul.json <<EOF
{
"server": true,
"ui":true,
"data_dir": "/dev-data/consul-1.7.3/data",
"node_name": "node1",
"bootstrap_expect":1,
"client_addr": "0.0.0.0",
"bind_addr": "192.168.0.62"
}
EOF

cd /dev-data
 wget --no-check-certificate https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip
unzip consul_1.7.3_linux_amd64.zip
mv consul consul-1.7.3/consul
cd consul-1.7.3
ln -s /dev-data/consul-1.7.3/consul /usr/local/bin/consul

cat > /usr/lib/systemd/system/consul.service <<EOF
[Unit]
Description=consul server
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/consul agent -config-dir /dev-data/consul-1.7.3/conf
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemctl enable consul && systemctl start consul