FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends mariadb-server screen unzip curl redis-server && \
	curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	apt-get -y install --no-install-recommends nodejs && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/csmm-7dtd"
ENV FORCE_UPDATE=""
ENV HOSTNAME=""
ENV STEAM_API_KEY=""
ENV BOTTOKEN=""
ENV CLIENTSECRET=""
ENV CLIENTID=""
ENV DB_BKP_INTERV=90
ENV CSMM_DL_URL="https://github.com/CatalysmsServerManager/7-days-to-die-server-manager/archive/master.zip"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="csmm-7dtd"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048 && \
	sed -i '$a\[mysqld]\ninnodb-file-per-table=ON\ninnodb-large-prefix=ON\ncharacter-set-server=utf8mb4\ninnodb_default_row_format='DYNAMIC'' /etc/alternatives/my.cnf && \
	/etc/init.d/mysql start && \
	mysql -u root -e "CREATE USER IF NOT EXISTS 'csmm'@'%' IDENTIFIED BY 'csmm7dtd';FLUSH PRIVILEGES;" && \
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS 7dtd;" && \
	mysql -u root -e "GRANT ALL ON 7dtd.* TO 'csmm'@'%' IDENTIFIED BY 'csmm7dtd';" && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'CSMM7DtD';FLUSH PRIVILEGES;"

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]