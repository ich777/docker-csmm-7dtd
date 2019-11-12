FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install wget mariadb-server screen unzip curl redis-server
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -y install nodejs

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

RUN mkdir $DATA_DIR
RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID csmm-7dtd
RUN chown -R csmm-7dtd $DATA_DIR

RUN ulimit -n 2048

RUN sed -i '$a\[mysqld]\ninnodb-file-per-table=ON\ninnodb-large-prefix=ON\ncharacter-set-server=utf8mb4\ninnodb_default_row_format='DYNAMIC'' /etc/alternatives/my.cnf
RUN /etc/init.d/mysql start && \
	mysql -u root -e "CREATE USER IF NOT EXISTS 'csmm'@'%' IDENTIFIED BY 'csmm7dtd';FLUSH PRIVILEGES;" && \
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS 7dtd;" && \
	mysql -u root -e "GRANT ALL ON 7dtd.* TO 'csmm'@'%' IDENTIFIED BY 'csmm7dtd';" && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'CSMM7DtD';FLUSH PRIVILEGES;"

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R csmm-7dtd /opt/scripts
RUN chown -R csmm-7dtd:users /var/lib/mysql
RUN chmod -R 770 /var/lib/mysql
RUN chown -R csmm-7dtd:users /var/run/mysqld
RUN chmod -R 770 /var/run/mysqld
RUN chown -R csmm-7dtd /var/lib/redis
RUN chown -R csmm-7dtd /usr/bin/redis-server
RUN chown -R csmm-7dtd /usr/bin/redis-cli

USER csmm-7dtd

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]