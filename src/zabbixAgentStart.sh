#!/bin/sh
echo "allow all IPs on zabbix-agent" && \
sed -i -E "s/Server=127.0.0.1/Server=::\/0/" /etc/zabbix/zabbix_agentd.conf && \
echo "assign suffix to zabbix-agent's hostname" && \
sed -i -E "s/Hostname=Zabbix\ server/Hostname=Zabbix\ server\ agent/" /etc/zabbix/zabbix_agentd.conf && \
service zabbix-agent restart
