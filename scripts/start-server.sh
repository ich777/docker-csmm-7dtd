#!/bin/bash
echo "---Starting MariaDB...---"
screen -S MariaDB -L -Logfile ${DATA_DIR}/MariaDBLog.0 -d -m mysqld_safe
sleep 5

echo "---Starting Redis Server---"
screen -S RedisServer -L -Logfile ${DATA_DIR}/RedisLog.0 -d -m /usr/bin/redis-server
sleep 5

echo "---Checking if CSMM is installed---"
if [ ! -f ${DATA_DIR}/CSMM/app.js ]; then
	echo "---CSMM not found, installing---"
    cd ${DATA_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll ${CSMM_DL_URL} ; then
    	echo "---CSMM successfully downloaded, please wait---"
    else
    	echo "---Can't download CSMM, putting server into sleep mode---"
        sleep infinity
    fi
    unzip -q ${DATA_DIR}/master.zip
    rm ${DATA_DIR}/master.zip
    mv ${DATA_DIR}/7-days-to-die-server-manager-master ${DATA_DIR}/CSMM
    cd ${DATA_DIR}/CSMM
    npm install --only=prod
    if [ -d ${DATA_DIR}/.cache ]; then
		rm -R ${DATA_DIR}/.cache
    fi
    if [ -d ${DATA_DIR}/.npm ]; then
		rm -R ${DATA_DIR}/.npm
    fi
    if [ -d ${DATA_DIR}/.config ]; then
		rm -R ${DATA_DIR}/.config
    fi
    if [ -f ${DATA_DIR}/.wget-hsts ]; then
		rm ${DATA_DIR}/.wget-hsts
    fi
    find ${DATA_DIR} -name ".config" -exec rm -R -f {} \;
    find ${DATA_DIR} -name ".npm" -exec rm -R -f {} \;
    find ${DATA_DIR} -name ".wget-hsts" -exec rm -R -f {} \;
    cp ${DATA_DIR}/CSMM/.env.example ${DATA_DIR}/CSMM/.env
    echo "---CSMM successfully installed---"
elif [ "${FORCE_UPDATE}" == "true" ]; then
	echo "---Force Update activated, installing CSMM---"
    cd ${DATA_DIR}
    rm -R ${DATA_DIR}/CSMM
    if wget -q -nc --show-progress --progress=bar:force:noscroll ${CSMM_DL_URL} ; then
    	echo "---CSMM successfully downloaded, please wait---"
    else
    	echo "---Can't download CSMM, putting server into sleep mode---"
        sleep infinity
    fi
    unzip -q ${DATA_DIR}/master.zip
    rm ${DATA_DIR}/master.zip
    mv ${DATA_DIR}/7-days-to-die-server-manager-master ${DATA_DIR}/CSMM
    cd ${DATA_DIR}/CSMM
    npm install --only=prod
    if [ -d ${DATA_DIR}/.cache ]; then
		rm -R ${DATA_DIR}/.cache
    fi
    if [ -d ${DATA_DIR}/.npm ]; then
		rm -R ${DATA_DIR}/.npm
    fi
    if [ -d ${DATA_DIR}/.config ]; then
		rm -R ${DATA_DIR}/.config
    fi
    if [ -f ${DATA_DIR}/.wget-hsts ]; then
		rm ${DATA_DIR}/.wget-hsts
    fi
    cp ${DATA_DIR}/CSMM/.env.example ${DATA_DIR}/CSMM/.env
    echo "---Force Update finished, CSMM successfully installed---"
else
	echo "---CSMM found---"
fi

echo "---Prepare Server---"
if [ ! -d ${DATA_DIR}/Database ]; then
	mkdir ${DATA_DIR}/Database
fi
echo "---Configuring Redis---"
sleep 5
echo "CONFIG SET dir ${DATA_DIR}/Database" | redis-cli
echo "CONFIG SET dbfilename redis.rdb" | redis-cli
echo "BGSAVE" | redis-cli
echo "---Checking for old logs---"
find ${DATA_DIR} -name "MariaDBLog.0" -exec rm -f {} \;
find ${DATA_DIR} -name "RedisLog.0" -exec rm -f {} \;
echo "---Configuring CSMM---"
if [ "${HOSTNAME}" == "" ]; then
	echo "---Hostname can't be empty, putting server into sleep mode---"
    sleep infinity
fi
if [ "${STEAM_API_KEY}" == "" ]; then
	echo "---Steam API Key can't be empty, putting server into sleep mode---"
    sleep infinity
fi
sed -i "/CSMM_HOSTNAME=/c\CSMM_HOSTNAME=${HOSTNAME}" ${DATA_DIR}/CSMM/.env
sed -i "/API_KEY_STEAM=/c\API_KEY_STEAM=${STEAM_API_KEY}" ${DATA_DIR}/CSMM/.env
sed -i "/DISCORDBOTTOKEN=/c\DISCORDBOTTOKEN=${BOTTOKEN}" ${DATA_DIR}/CSMM/.env
sed -i "/DISCORDCLIENTSECRET=/c\DISCORDCLIENTSECRET=${CLIENTSECRET}" ${DATA_DIR}/CSMM/.env
sed -i "/DISCORDCLIENTID=/c\DISCORDCLIENTID=${CLIENTID}" ${DATA_DIR}/CSMM/.env
sed -i "/DBSTRING=/c\DBSTRING=mysql2://csmm:csmm7dtd@127.0.0.1:3306/7dtd" ${DATA_DIR}/CSMM/.env
sed -i "/REDISSTRING=/c\REDISSTRING=redis://127.0.0.1:6379" ${DATA_DIR}/CSMM/.env

echo "---Checking if Databse is present---"
if [ -f ${DATA_DIR}/Database/7dtd.sql ]; then
	echo "---Database found, injecting, please wait---"
	mysql -u "csmm" -p"csmm7dtd" 7dtd < ${DATA_DIR}/Database/7dtd.sql
    export NODE_ENV=production
else
	echo "--------------------------------------------------------------"
	echo "---Please wait initializing CSMM this will take ~60 seconds---"
    echo "-------the CSMM will restart automatically after that it------"
    echo "--------------------------------------------------------------"
    sleep 5
    cd ${DATA_DIR}/CSMM
    timeout 60 nodejs ${DATA_DIR}/CSMM/app.js
    export NODE_ENV=production
fi
sleep 3
screen -S BackupDatabase -L -d -m /opt/scripts/backup-database.sh
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Start Server---"
cd ${DATA_DIR}/CSMM
nodejs ${DATA_DIR}/CSMM/app.js