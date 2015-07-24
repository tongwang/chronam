#!/usr/bin/env bash

LOG_FILE=install.log

log "download batch_uuml_thys_ver01 for use as test data"
cd ${chronamDir}/data
wget --quiet --recursive --no-host-directories --cut-dirs 1 --reject index.html* --include-directories /data/batches/batch_uuml_thys_ver01/ http://chroniclingamerica.loc.gov/data/batches/batch_uuml_thys_ver01/

sed -i -E "s#/opt/chronam#${chronamDir}#" ${chronamDir}/settings.py

log "load downloaded data into chronam"
django-admin.py load_batch ${chronamDir}/data/batches/batch_uuml_thys_ver01 >> $LOG_FILE
