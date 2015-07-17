#1/usr/bin/env bash

function realpath {
  perl -MCwd -e 'print Cwd::realpath ($ARGV[0]), qq<\n>' $0
}

LOG_FILE=install.log

function log() {
  echo $1 >> /dev/stdout
  echo $1 >> ${LOG_FILE}
}

#so that the install doesn't prompt us for a password
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password'

fullScriptPath=`realpath $0`
installDir=`dirname $fullScriptPath`
solrVersion="4.10.4"
solrTarFile="solr-${solrVersion}.tgz"
solrDownload="http://archive.apache.org/dist/lucene/solr/${solrVersion}/${solrTarFile}"
solrHome=/usr/share/jetty8
solrCollectionConfigDir=${solrHome}/solr/collection1/conf
solrCollectionConfigFiles=("${installDir}/../conf/schema.xml" "${installDir}/../conf/solrconfig.xml")

#echo "installDir is $installDir"

aptGetDependencies=("python-dev" "python-virtualenv" "mysql-server" "libmysqlclient-dev" "apache2" "libapache2-mod-wsgi" "jetty8" "libxml2-dev" "libxslt-dev" "libjpeg-dev" "graphicsmagick")

log "install dependencies"
if [ `which apt-get` != "" ]
then
  #use apt-get to install dependencies
  log "Update packages"
  sudo apt-get update
  log "Install ${aptGetDependencies[@]}"
  sudo apt-get install ${aptGetDependencies[@]} -y
fi

log "install solr ${solrVersion}"
if [ ! -f ${solrTarFile} ]
then
  wget ${solrDownload}
  log "untar ${solrTarFile}"
  tar zxf ${solrTarFile}
fi

#only copy files that aren't already in jetty
log "Running sudo rsync -r --ignore-existing solr-${solrVersion}/example ${solrHome}"
sudo rsync --recursive --ignore-existing solr-${solrVersion}/example/ ${solrHome}

#ensure the destination exists
sudo mkdir -p ${solrCollectionConfigDir}

for config in ${solrCollectionConfigFiles[@]}
do
  log "install ${config} file to ${solrCollectionConfigDir}"
  sudo cp ${config} ${solrCollectionConfigDir}
done

log "enable jetty to startup"
#use regex to replace NO_START=0 to NO_START=1 while creating a backup with the extension .bck
sudo sed --in-place=bck -E "s/NO_START\\=1/NO_START\\=0/" /etc/default/jetty8

log "change ${solrHome} to be owned by jetty user"
sudo chown -R jetty ${solrHome}

log "restart jetty service"
sudo service jetty8 restart
