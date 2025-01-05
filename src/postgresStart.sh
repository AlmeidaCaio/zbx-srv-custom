#!/bin/sh
localeCode=$1
echo "Postgres' version := ${PG_VERSION}" && \
{ echo "user1    root      postgres" >> /etc/postgresql/${PG_VERSION}/main/pg_ident.conf ; } && \
sed -E -i "s/#(listen_addresses\ =\ ')localhost('.*)/\1*\2/" /etc/postgresql/${PG_VERSION}/main/postgresql.conf && \
service postgresql restart && \
echo "setting up postgres structure for zabbix database" && \
su postgres -c 'createuser zabbix' && \
su postgres -c 'createdb -O zabbix -E Unicode -T template0 zabbix' && \
echo "extracting zabbix's database source from .gz" && \
{ gunzip -c /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz >> /src/server.sql ; } && \
echo "making zabbix's database into postgres" && \
su postgres -c bash -c "psql -d zabbix -f /src/server.sql -q" && \
echo "granting access rights to user zabbix" && \
su postgres -c bash -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;'" && \
su postgres -c bash -c "psql -c 'GRANT CONNECT ON DATABASE zabbix TO zabbix;'" && \
su postgres -c bash -c "psql -c 'GRANT pg_read_all_data TO zabbix;'" && \
su postgres -c bash -c "psql -c 'GRANT pg_write_all_data TO zabbix;'" && \
su postgres -c bash -c "psql -c 'GRANT USAGE ON SCHEMA public TO zabbix;'" && \
su postgres -c bash -c "psql -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO zabbix;'" && \
su postgres -c bash -c "psql -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO zabbix;'" && \
echo "setting up zabbix user's password" && \
su postgres -c bash -c "psql -f /src/postgresAdditionalStep01.sql -q" && \
echo "setting up preferences to standard zabbix user" && \
sed -i "s/zabbix_lang/${localeCode}/g" /src/postgresAdditionalStep02.sql && \
sed -i "s/zabbix_timezone/$( echo ${TZ} | sed 's/\//\\\//g' )/g" /src/postgresAdditionalStep02.sql && \
su postgres -c bash -c "psql -d zabbix -f /src/postgresAdditionalStep02.sql -q" && \
echo "enabling local password authentication" && \
sed -i -E 's/(local\s*all\s*all\s*)[a-z0-9]*/\1password/' /etc/postgresql/${PG_VERSION}/main/pg_hba.conf && \
echo "enabling remote access with zabbix user" && \
{ echo 'host    zabbix          zabbix          0.0.0.0/0               scram-sha-256' >> /etc/postgresql/${PG_VERSION}/main/pg_hba.conf ; } && \
{ echo 'host    zabbix          zabbix          ::/0                    scram-sha-256' >> /etc/postgresql/${PG_VERSION}/main/pg_hba.conf ; } && \
echo "Setup 'pg_ctl'" && \
ln -s /usr/lib/postgresql/${PG_VERSION}/bin/pg_ctl /usr/local/bin/pg_ctl
