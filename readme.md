# Readme!

##### **DISCLAIMER**: _This project is free and I do not own Zabbix, Postgres nor related dependencies. Furthermore, this project was made for learning purposes, since many new teammates were wishing for an easy local zabbix so they could run it on their personal machines._

---

1. Containerized Zabbix Server installation for Ubuntu 22.04 following [official package documentation](https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=22.04&components=server_frontend_agent&db=pgsql&ws=nginx) steps.

2. Compatible _container engines_ versions:
   * Podman >= 3.4.4 
   * Docker >= 20

3. For container image building through _containerfile_, a file named **pgsql_password.txt** must be created in this directory with a single line content; e.g.:
    ```
    z@b'B!X`$T&$t!
    ```
    will be the password to the DBMS SA's.

4. Locale Code is by default "pt_BR" end ports **80**, **5432**, **10050** and **10051** must be mapped whenever instantiating a container; e.g., using _podman_:
    ```
    podman image build -f ./containerfile --build-arg LOC_CODE=en_AU -t zbx-srv-custom:1.00 ./
    podman container run -itd -p 41234:80 -p 41235:5432 -p 41236-41237:10050-10051 zbx-srv-custom:1.00
    ```

5. For this **Zabbix's 1st access**, one needs to follow the [official quickstart guide here](https://www.zabbix.com/documentation/7.0/en/manual/quickstart/login).

6. If one needs to access Zabbix Server's local database, user "zabbix" over the named database "zabbix" can be used, i.e.:
    ```
    psql -U zabbix -d zabbix -W
    ```
