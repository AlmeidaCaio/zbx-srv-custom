#!/bin/sh
zbxServerName=$1
echo "zabbix-server's name setup to '${zbxServerName}'" && \
sed -i "s/zabbix_servername/$( echo ${zbxServerName} \
    | sed 's/\!/\\\!/g' \
    | sed 's/\$/\\\$/g' \
    | sed 's/&/\\&/g' \
    | sed 's/`/\\`/g' \
    | sed 's/\x27/\\\\\x27/g' )/g" /src/zabbixWebConfig.php && \
cp /src/zabbixWebConfig.php /etc/zabbix/web/zabbix.conf.php && \
chmod 600 /etc/zabbix/web/zabbix.conf.php && \
chown www-data\:www-data /etc/zabbix/web/zabbix.conf.php && \
ln -s /etc/zabbix/web/zabbix.conf.php /usr/share/zabbix/conf/zabbix.conf.php ; \
echo "set up zabbix database public schema for zabbix-server" && \
sed -i -E 's/#\ DBSchema=/DBSchema=public/' /etc/zabbix/zabbix_server.conf && \
echo "set up zabbix database password for zabbix-server" && \
sed -i -E 's/#\ DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf && \
echo "allow any IPs into zabbix-server interface" && \
sed -i -E 's/StatsAllowedIP=127.0.0.1/StatsAllowedIP=::\/0/' /etc/zabbix/zabbix_server.conf && \
service zabbix-server restart
