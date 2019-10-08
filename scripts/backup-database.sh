while true ; do
	mysqldump -u csmm -p"csmm7dtd" 7dtd > $DATA_DIR/Database/7dtd.sql
	sleep ${DB_BKP_INTERV}
done