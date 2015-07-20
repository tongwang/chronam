#1/usr/bin/env bash

aptGetDependencies=("python-dev" "python-virtualenv" "mysql-server" "libmysqlclient-dev" "apache2" "libapache2-mod-wsgi" "jetty8" "libxml2-dev" "libxslt-dev" "libjpeg-dev" "graphicsmagick")
aptGetMysqlDependencies=("mysql-server" "libmysqlclient-dev")

log "install dependencies"
if [ `which apt-get` != "" ]
then
  #use apt-get to install dependencies
  log "Update packages"
  sudo apt-get update >> $LOG_FILE
  
  log "Install ${aptGetDependencies[@]}"
  sudo apt-get install ${aptGetDependencies[@]} -y >> $LOG_FILE
  #install the mysql dependencies separately cause they will need a root password
  sudo apt-get install ${aptGetMysqlDependencies[@]} -y 
fi
