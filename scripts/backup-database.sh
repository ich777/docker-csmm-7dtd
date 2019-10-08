while true ; do
	mysqldump -u csmm -p"csmm7dtd" 7dtd > $DATA_DIR/Database/7dtd-1.sql
	sleep 60
	mysqldump -u csmm -p"csmm7dtd" 7dtd > $DATA_DIR/Database/7dtd-2.sql
	sleep 60
done