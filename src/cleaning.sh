#!/bin/sh
enableGlobalScriptsFlag=$1
zabbixVersion=$2
apt-get clean
if [ ${enableGlobalScriptsFlag} -eq "1" ] ; then
    echo "flag '1' : only cleans Ubuntu Server" 
else
    echo "flag not '1' : cleans and reduces Ubuntu Server"
    apt-get remove --purge -y wget
    rm -rf /var/lib/apt/lists/*
fi
rm "/zabbix-release_${zabbixVersion}+ubuntu22.04_all.deb"
