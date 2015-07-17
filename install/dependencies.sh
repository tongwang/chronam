#1/usr/bin/env bash

aptGetDependencies=("python-dev" "python-virtualenv" "mysql-server" "libmysqlclient-dev" "apache2" "libapache2-mod-wsgi" "jetty8" "libxml2-dev" "libxslt-dev" "libjpeg-dev" "graphicsmagick")

log "install dependencies"
if [ `which apt-get` != "" ]
then
  #use apt-get to install dependencies
  log "Update packages"
  sudo apt-get update
  
  #so that the install doesn't prompt us for a password
  sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password '
  sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '

  log "Install ${aptGetDependencies[@]}"
  sudo apt-get install ${aptGetDependencies[@]} -y
fi
