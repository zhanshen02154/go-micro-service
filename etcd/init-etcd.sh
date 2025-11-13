#!/bin/bash

DEV_DATAPATH=/dev-data

# wget 
if [ ! -d $DEV_DATAPATH ]; then
	mkdir -p $DEV_DATAPATH
fi

cd $DEV_DATAPATH/etcd-v3.5.7-linux-amd64
mv conf/etcd.yaml conf/etcd.yaml.bak
cat > conf/etcd.yaml <<EOF
name: "etcd-node-1"
data-dir: "/var/lib/etcd"
initial-cluster-token: "J7HYkyZwwuUZFa4RFVLV"
listen-client-urls: "http://0.0.0.0:2379"
listen-peer-urls: "http://0.0.0.0:2380"
advertise-client-urls: "http://192.168.83.131:2379"
initial-advertise-peer-urls: "http://192.168.83.131:2380"
initial-cluster: "etcd-node-1=http://192.168.83.131:2380"
initial-cluster-state: "new"
auto-compaction-retention: "1"
quota-backend-bytes: 2147483648
EOF

chmod +x $DEV_DATAPATH/etcd-v3.5.7-linux-amd64/etcd
chmod +x $DEV_DATAPATH/etcd-v3.5.7-linux-amd64/etcdctl
chmod +x $DEV_DATAPATH/etcd-v3.5.7-linux-amd64/etcdutl

ln -s $DEV_DATAPATH/etcd-v3.5.7-linux-amd64/etcd /usr/local/bin/etcd
ln -s $DEV_DATAPATH/etcd-v3.5.7-linux-amd64/etcdctl /usr/local/bin/etcdctl
ln -s $DEV_DATAPATH/etcd-v3.5.7-linux-amd64/etcdutl /usr/local/bin/etcdutl

chmod +x /usr/local/bin/etcd
chmod +x /usr/local/bin/etcdctl
chmod +x /usr/local/bin/etcdutl

cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd --config-file=/dev-data/etcd-v3.5.7-linux-amd64/conf/etcd.yaml
Restart=always
RestartSec=5s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd