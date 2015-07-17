#1/usr/bin/env bash

solrVersion="4.10.4"
solrTarFile="solr-${solrVersion}.tgz"
solrDownload="http://archive.apache.org/dist/lucene/solr/${solrVersion}/${solrTarFile}"
solrHome=/usr/share/jetty8
solrCollectionConfigDir=${solrHome}/solr/collection1/conf
solrCollectionConfigFiles=("${installDir}/../conf/schema.xml" "${installDir}/../conf/solrconfig.xml")

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
