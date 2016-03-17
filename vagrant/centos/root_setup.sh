#!/usr/bin/env bash
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

yum -y install mysql-server mysql-devel python-virtualenv gcc libxml2-devel libxslt-devel libjpeg-devel zlib-devel java-1.6.0-openjdk-devel git

yum -y install GraphicsMagick

CHRONAM_HOME=/opt/chronam
SOLR_HOME=/opt/solr

# install Solr
useradd -d /opt/solr -s /bin/bash solr

wget http://archive.apache.org/dist/lucene/solr/4.4.0/solr-4.4.0.tgz
tar zxvf solr-4.4.0.tgz
install -d -o vagrant -g vagrant -m 755 /opt/solr
mv solr-4.4.0/example/* /opt/solr/
cp $CHRONAM_HOME/conf/schema.xml $SOLR_HOME/solr/collection1/conf/schema.xml
cp $CHRONAM_HOME/conf/solrconfig.xml $SOLR_HOME/solr/collection1/conf/solrconfig.xml
cp $CHRONAM_HOME/conf/jetty-logging.xml $SOLR_HOME/etc/jetty-logging.xml
chown solr:solr -R $SOLR_HOME

# Jetty for Solr
cp $CHRONAM_HOME/conf/jetty7.sh /etc/init.d/jetty
chmod +x /etc/init.d/jetty
cp $CHRONAM_HOME/conf/jetty-redhat /etc/default/jetty
# replace "-Xms2g -Xmx2g" with "-Xms256m -Xmx256m" because 2g is too large for dev VM
sed -i -- 's/-Xms2g -Xmx2g/-Xms256m -Xmx256m/g' /etc/default/jetty

chkconfig --levels 235 jetty on
service jetty start

# start MySQL
chkconfig --levels 235 mysqld on
service mysqld start