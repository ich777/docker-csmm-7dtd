#!/bin/bash
echo "---Checking for old logs---"
find ${DATA_DIR} -name "CSMMLog.0" -exec rm -f {} \;
find ${DATA_DIR} -name "MariaDBLog.0" -exec rm -f {} \;
find ${DATA_DIR} -name "RedisLog.0" -exec rm -f {} \;

echo "---Starting MariaDB...---"
screen -S MariaDB -L -Logfile ${DATA_DIR}/MariaDBLog.0 -d -m mysqld_safe
sleep 5

echo "---Starting Redis Server---"
screen -S RedisServer -L -Logfile ${DATA_DIR}/RedisLog.0 -d -m /usr/bin/redis-server
sleep 5

echo "---Prepare Server---"
if [ ! -d ${DATA_DIR}/Database ]; then
	mkdir ${DATA_DIR}/Database
fi
echo "---Checking if Database is present---"
if [ ! -f ${DATA_DIR}/Database/7dtd.sql ]; then
	if wget -q https://raw.githubusercontent.com/ich777/docker-csmm-7dtd/master/database/7dtd.sql ; then
		echo "---Sucessfully downloaded Database---"
	else
		echo "---Something went wrong, can't download Database, putting server in sleep mode---"
		sleep infinity
else
	echo "---Database found!---"
fi

echo "---Injecting Database---"
mysql -u "csmm" -p"csmm7dtd" -e "SOURCE ${DATA_DIR}/Database/7dtd.sql"
chmod -R 770 ${DATA_DIR}


echo "---Sleep zZz---"
sleep infinity


cd ${DATA_DIR}
wget -q --show-progress https://github.com/CatalysmsServerManager/7-days-to-die-server-manager/archive/master.zip
unzip ${DATA_DIR}/master.zip
cd ${DATA_DIR}/7-days-to-die-server-manager-master
npm install --only=prod
cp ${DATA_DIR}/7-days-to-die-server-manager-master/.env.example ${DATA_DIR}/7-days-to-die-server-manager-master/.env



DBSTRING=mysql2://csmm:csmm-7dtd@localhost:3306/7dtd
REDISSTRING=redis://127.0.0.1:6379

nodejs app.js



echo "---Checking if CSMM is configured correctly for database connection---"
if grep -rq 'Username = changeme' ${DATA_DIR}//extdb-conf.ini; then
	sed -i '/Username = changeme/c\Username = csmm' ${DATA_DIR}//extdb-conf.ini
	sed -i '/Username = csmm/!b;n;cPassword = csmm' ${DATA_DIR}//extdb-conf.ini
    echo "---Corrected ExileMod database connection---"
fi

if grep -rq 'Username = csmm' ${DATA_DIR}//extdb-conf.ini; then
	if grep -rq 'Password = csmm' ${DATA_DIR}//extdb-conf.ini; then
    	:
    else
    	sed -i '/Username = csmm/!b;n;cPassword = csmm' ${DATA_DIR}//extdb-conf.ini
    fi
	echo "---CSMM database connection correct---"
fi

echo "---Prepare Server---"
if [ ! -d ${DATA_DIR}/Database ]; then
	mkdir ${DATA_DIR}/Database
fi
echo "---Checking if Database is present---"
if [ ! -f ${DATA_DIR}/Database/7dtd.sql ]; then
	if wget -q https://raw.githubusercontent.com/ich777/docker-csmm-7dtd/master/database/7dtd.sql ; then
		echo "---Sucessfully downloaded Database---"
	else
		echo "---Something went wrong, can't download Database, putting server in sleep mode---"
		sleep infinity
else
	echo "---Database found!---"
fi

echo "---Injecting Database---"
mysql -u "csmm" -p"csmm7dtd" -e "SOURCE ${DATA_DIR}/Database/7dtd.sql"
chmod -R 770 ${DATA_DIR}

echo "---Start Server---"
cd ${DATA_DIR}


tail -f ${DATA_DIR}/MariaDBLog.0 ${DATA_DIR}/CSSMLog.0