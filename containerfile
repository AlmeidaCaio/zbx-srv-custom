# Global Argument, should not be "docker.io/library/ubuntu:22.04"
ARG UBUNTU_NGINX="docker.io/ubuntu/nginx:1.18-22.04_beta"

# Setup Ubuntu, environment variables and ports
FROM ${UBUNTU_NGINX}
ARG ENABLE_GLOBAL_SCRIPTS="1"
ARG LOC_CODE="pt_BR" 
ARG POSTGRES_VERSION="16" 
ARG TIMEZONE_IDENTIFIER="America/Bahia" 
ARG ZABBIX_SERVERNAME="ZBX-VERSION-α" 
ARG ZABBIX_VERSION="7.0-2"
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=${LOC_CODE}.UTF-8 \
    LANGUAGE=${LOC_CODE}:en \
    LC_ALL=${LOC_CODE}.UTF-8 \
    PG_VERSION=${POSTGRES_VERSION} \
    TZ=${TIMEZONE_IDENTIFIER}
EXPOSE 80 \
    5432 \
    10050 \
    10051
WORKDIR /

# Set default language with UTF-8 encoding and TimeZone
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales tzdata \
    && sed -i "s/^# \(en_US.UTF-8\)/\1/g" /etc/locale.gen \
    && sed -i "s/^# \(${LANG}\)/\1/g" /etc/locale.gen \
    && locale-gen \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

# Install PHP and GPGs, and setup repositories of Zabbix and PostgreSQL
RUN apt-get install -y ca-certificates wget \
    && apt-get install -y php-fpm php-mysql php-mbstring php-xml php-gd php-curl php-bcmath php-ldap \
    && apt install -y gnupg postgresql-common \
    && wget https://repo.zabbix.com/zabbix/$( echo ${ZABBIX_VERSION} | sed -E 's/-[0-9]*//g' )/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VERSION}%2Bubuntu22.04_all.deb \
    && apt install -y "/zabbix-release_${ZABBIX_VERSION}+ubuntu22.04_all.deb" \
    && apt update \
    && bash -c "/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh < <( echo '' )"

# Install Zabbix and PostgreSQL
RUN bash -c "cat <( echo -e '\n# Includes zabbix-sql-scripts folder\npath-include=/usr/share/doc/zabbix-sql-scripts/*\n' ) >> /etc/dpkg/dpkg.cfg.d/excludes" \
    && apt install -y php8.1-pgsql postgresql-${PG_VERSION} zabbix-agent zabbix-frontend-php zabbix-nginx-conf zabbix-server-pgsql zabbix-sql-scripts

# Load input files
ADD ./src /src
COPY ./pgsql_password.txt /src/
RUN chmod +x /src/*

# NGINX setup
RUN mv /src/nginx.conf /etc/nginx/sites-available/default \
    && nginx -t

# Load DBMS password file
RUN sed -i 's/\!/\\\!/g' /src/pgsql_password.txt \
    && sed -i 's/\$/\\\$/g' /src/pgsql_password.txt \
    && sed -i 's/&/\\&/g' /src/pgsql_password.txt \
    && sed -i 's/`/\\`/g' /src/pgsql_password.txt \
    && sed -i "s/zabbix_password/$( cat /src/pgsql_password.txt | sed 's/\x27/\\\\\x27/g' )/g" /src/zabbixWebConfig.php \
    && sed -i "s/zabbix_password/$( cat /src/pgsql_password.txt | sed 's/\\/\\\\\\/g' | sed 's/\x27/\\\\x27/g' )/g" /src/zabbixServerStart.sh \
    && sed -i "s/zabbix_password/$( cat /src/pgsql_password.txt | sed 's/\x27/\x27\x27/g' )/g" /src/postgresAdditionalStep01.sql

# Final services' setup
RUN /src/enableGlobalUtilities.sh ${ENABLE_GLOBAL_SCRIPTS} \
    && /src/postgresStart.sh ${LOC_CODE} \
    && /src/zabbixServerStart.sh ${ZABBIX_SERVERNAME} \
    && /src/nginxPhpStart.sh \
    && /src/zabbixAgentStart.sh \
    && mv /src/containerStarter.sh /docker-entrypoint.d/ 

# Volumes externalization
VOLUME [ "/var/log", "/var/lib/postgresql/${PG_VERSION}/main" ]

# Remove unnecessary apt data (and for security reasons)
RUN /src/cleaning.sh ${ENABLE_GLOBAL_SCRIPTS} ${ZABBIX_VERSION} \
    && rm -r /src
