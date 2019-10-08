#!/bin/bash
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "CSMMLog.0" -exec rm -f {} \;
find ${SERVER_DIR} -name "MariaDBLog.0" -exec rm -f {} \;

echo "---Starting MariaDB...---"
screen -S MariaDB -L -Logfile ${SERVER_DIR}/MariaDBLog.0 -d -m mysqld_safe
sleep 10

echo "---Checking if CSMM is configured correctly for database connection---"
if grep -rq 'Username = changeme' ${SERVER_DIR}//extdb-conf.ini; then
	sed -i '/Username = changeme/c\Username = csmm' ${SERVER_DIR}//extdb-conf.ini
	sed -i '/Username = csmm/!b;n;cPassword = csmm' ${SERVER_DIR}//extdb-conf.ini
    echo "---Corrected ExileMod database connection---"
fi

if grep -rq 'Username = csmm' ${SERVER_DIR}//extdb-conf.ini; then
	if grep -rq 'Password = csmm' ${SERVER_DIR}//extdb-conf.ini; then
    	:
    else
    	sed -i '/Username = csmm/!b;n;cPassword = csmm' ${SERVER_DIR}//extdb-conf.ini
    fi
	echo "---CSMM database connection correct---"
fi

echo "---Prepare Server---"
chmod -R 770 ${DATA_DIR}

echo "---Start Server---"
cd ${SERVER_DIR}


tail -f ${SERVER_DIR}/MariaDBLog.0 ${SERVER_DIR}/CSSMLog.0