FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install wget mariadb-server screen unzip

ENV DATA_DIR="/csmm"
ENV CSMM_DL_URL="https://github.com/CatalysmsServerManager/7-days-to-die-server-manager/archive/master.zip"
ENV MARIA_DB_ROOT_PWD="CSMM"
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID csmm
RUN chown -R csmm $DATA_DIR

RUN ulimit -n 2048

RUN /etc/init.d/mysql start && \
	mysql -u root -e "CREATE USER IF NOT EXISTS 'csmm'@'%' IDENTIFIED BY 'csmm';FLUSH PRIVILEGES;" && \
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS csmm;" && \
	mysql -u root -e "GRANT ALL ON csmm.* TO 'csmm'@'%' IDENTIFIED BY 'csmm';" && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MARIA_DB_ROOT_PWD';FLUSH PRIVILEGES;"

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R csmm /opt/scripts
RUN chown -R csmm:users /var/lib/mysql
RUN chmod -R 770 /var/lib/mysql
RUN chown -R csmm:users /var/run/mysqld
RUN chmod -R 770 /var/run/mysqld

USER csmm

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]