#1/usr/bin/env bash

solrVersion="4.10.4"
solrTarFile="solr-${solrVersion}.tgz"
solrDownload="http://archive.apache.org/dist/lucene/solr/${solrVersion}/${solrTarFile}"
solrHome=/usr/share/jetty8
solrCollectionConfigDir=${solrHome}/solr/collection1/conf
solrCollectionConfigFiles=("${chronamDir}/conf/schema.xml" "${chronamDir}/conf/solrconfig.xml")

log "install solr ${solrVersion}"
if [ ! -f ${solrTarFile} ]
then
  wget ${solrDownload} >> $LOG_FILE
  log "untar ${solrTarFile}"
  tar zxf ${solrTarFile}
fi

#only copy files that aren't already in jetty
sudo rsync --recursive --ignore-existing solr-${solrVersion}/example/ ${solrHome} >> $LOG_FILE

#ensure the destination exists
sudo mkdir -p ${solrCollectionConfigDir} >> $LOG_FILE

for config in ${solrCollectionConfigFiles[@]}
do
  log "install ${config} file to ${solrCollectionConfigDir}"
  sudo cp ${config} ${solrCollectionConfigDir} >> $LOG_FILE
done

log "enable jetty to startup"
#use regex to replace NO_START=0 to NO_START=1 while creating a backup with the extension .bck
sudo sed --in-place=bck -E "s/NO_START\\=1/NO_START\\=0/" /etc/default/jetty8 >> $LOG_FILE

log "change ${solrHome} to be owned by jetty user"
sudo chown -R jetty ${solrHome} >> $LOG_FILE

log "restart jetty service"
sudo service jetty8 restart >> $LOG_FILE
