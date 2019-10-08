FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install wget mariadb-server screen unzip curl redis-server
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -y install nodejs

ENV DATA_DIR="/csmm-7dtd"
ENV CSMM_DL_URL="https://github.com/CatalysmsServerManager/7-days-to-die-server-manager/archive/master.zip"
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID csmm-7dtd
RUN chown -R csmm-7dtd $DATA_DIR

RUN ulimit -n 2048

RUN /etc/init.d/mysql start && \
	mysql -u root -e "CREATE USER IF NOT EXISTS 'csmm'@'%' IDENTIFIED BY 'csmm7dtd';FLUSH PRIVILEGES;" && \
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS 7dtd;" && \
	mysql -u root -e "GRANT ALL ON 7dtd.* TO 'csmm'@'%' IDENTIFIED BY 'csmm7dtd';" && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'CSMM7DtD';FLUSH PRIVILEGES;"
RUN sed -i '$a\[mysqld]\ninit_connect = "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"' /etc/alternatives/my.cnf

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