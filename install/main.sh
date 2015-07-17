#1/usr/bin/env bash

function realpath {
  perl -MCwd -e 'print Cwd::realpath ($ARGV[0]), qq<\n>' $0
}

function log {
  echo $0 >> /dev/stdout
  echo $0 >> install.log
}

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
  tar zxvf solr-${solrVersion}.tgz
fi

#only copy files that aren't already in jetty
sudo rsync -r --ignore-existing solr-${solrVersion}/example ${solrHome}

for config in ${solrCollectionConfigFiles[@]}
do
  log "install ${config} file to ${solrCollectionConfigDir}"
  sudo cp ${config} ${solrCollectionConfigDir}
done

log "enable jetty to startup"
#use regex to replace NO_START=0 to NO_START=1 while creating a backup with the extension .bck
sed -i ".bck" -E "s/NO_START\\=0/NO_START\\=1" /etc/default/jetty8

log "change ${solrHome} to be owned by jetty user"
sudo chown -R jetty ${solrHome}

log "restart jetty service"
sudo service jetty8 restart
