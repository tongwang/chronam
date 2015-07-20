#1/usr/bin/env bash

chronamPassword=chronam

sudo service mysql restart >> $LOG_FILE

log "create chronam user and database"
echo "DROP DATABASE IF EXISTS chronam; CREATE DATABASE chronam CHARACTER SET utf8; GRANT ALL ON chronam.* to 'chronam'@'localhost' identified by '${chronamPassword}'; GRANT ALL ON test_chronam.* TO 'chronam'@'localhost' identified by '${chronamPassword}';" | mysql -u root -p 

cp ${chronamDir}/settings_template.py ${chronamDir}/settings.py

#use regex to replace 'PASSWORD': 'pick_one' with ${chronamPassword}
sed -i -E "s/'PASSWORD': 'pick_one'/'PASSWORD': '${chronamPassword}'/" ${chronamDir}/settings.py >> $LOG_FILE
