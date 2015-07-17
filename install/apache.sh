#1/usr/bin/env bash

sudo a2enmod cache expires rewrite disk_cache
sudo cp ${chronamDir}/conf/chronam.conf /etc/apache2/sites-available/chronam.conf
sudo a2ensite chronam
sudo install -o $USER -g users -d ${chronamDir}/static
sudo install -o $USER -g users -d ${chronamDir}/.python-eggs
sudo service apache2 reload
