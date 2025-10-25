#!/bin/bash

# mkdir -p /dev-data
cd /dev-data
# wget --no-check-certificate https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz
tar -zxvf mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz
cd mysql-5.7.26-linux-glibc2.12-x86_64

cat > /etc/my.cnf <<EOF
[mysqld]
port=3306
datadir=/usr/local/mysql/data
basedir=/usr/local/mysql
socket=/usr/local/mysql/mysql.sock
max_connections=1000
max_connect_errors=10
character-set-server=utf8mb4
default-storage-engine=INNODB
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
log_error_verbosity=2
key_buffer_size=256M
max_allowed_packet=64M
slow_query_log=1
long_query_time=1
log_error=/var/log/mysql/error-%Y-%m-%d.log
slow_query_log_file=/var/log/mysql/slow_query-%Y-%m-%d.log
character-set-server=utf8mb4
symbolic-links=0
innodb_buffer_pool_size=128M

[mysqldump]
quick
max_allowed_packet=64M

[isamchk]
key_buffer_size=20M
sort_buffer_size=20M
read_buffer_size=2M
write_buffer_size=2M

[myisamchk]
key_buffer_size=20M
sort_buffer_size_size=20M
read_buffer_size=2M
write_buffer_size=2M
EOF

ln -s /dev-data/mysql-5.7.26-linux-glibc2.12-x86_64/bin /usr/local/mysql/bin

useradd -r -g mysql -s /bin/false mysql

mkdir -p /usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql/

echo 'export PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh

mkdir -p /var/log/mysql
mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --log_error=/var/log/mysql/error.log

cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
systemctl start mysqld