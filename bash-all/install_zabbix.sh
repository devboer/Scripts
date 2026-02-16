#! /usr/bin/env bash

# Step 1: Install Zabbix Repo
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
dpkg -i zabbix-release_7.0-2+debian12_all.deb
rm zabbix-release_7.0.2+debian12_all.deb
apt update

# Step 2: Install Zabbix
apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

# Step 3: Initialize Database
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

# Step 4: Configure
echo "Edit file /etc/zabbix/zabbix_server.conf"
echo "DBPassword=password"
sleep 1
echo "Edit file /etc/zabbix/nginx.conf uncomment and set 'listen' and 'server_name' directives."
echo "# listen 8080;"
echo "# server_name example.com;"
sleep 1
echo "Start Zabbix server and agent processes and make it start at system boot."
echo "systemctl restart zabbix-server zabbix-agent nginx php8.2-fpm"
echo "systemctl enable zabbix-server zabbix-agent nginx php8.2-fpm"


