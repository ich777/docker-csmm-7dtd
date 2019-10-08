while true ; do
	mysqldump -u csmm -p"csmm7dtd" 7dtd > $DATA_DIR/Database/7dtd.sql
	sleep 60
done