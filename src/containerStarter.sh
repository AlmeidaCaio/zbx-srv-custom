#!/bin/sh
service php8.1-fpm restart && \
service zabbix-agent restart && \
service zabbix-server restart && \
su postgres -c bash -c "pg_ctl restart -D /var/lib/postgresql/${PG_VERSION}/main/ -l /var/log/postgresql/postgresql-${PG_VERSION}-main.log -s" ; \
service --status-all
exit 0
