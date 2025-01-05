#!/bin/sh
enableGlobalScriptsFlag=$1
echo "flag of global script execution := '${enableGlobalScriptsFlag}'"
if [ ${enableGlobalScriptsFlag} -eq "1" ] ; then
    sed -i 's/EnableGlobalScripts=0/EnableGlobalScripts=1/g' /etc/zabbix/zabbix_server.conf && \
    apt-get install -y --no-install-recommends curl \
        iputils-* \
        netcat \
        nmap \
        ssh \
        sudo \
        telnet \
        traceroute 
elif [ ${enableGlobalScriptsFlag} -eq "0" ] ; then
    exit 0
else
    echo "flag '${enableGlobalScriptsFlag}' not recognized, needs to be either '1' or '0'." 1>&2
    exit 0
fi
