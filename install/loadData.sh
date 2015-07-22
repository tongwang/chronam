#!/usr/bin/env bash

LOG_FILE=install.log

cd ${chronamDir}/data
wget --recursive --no-host-directories --cut-dirs 1 --reject index.html* --include-directories /data/batches/batch_uuml_thys_ver01/ http://chroniclingamerica.loc.gov/data/batches/batch_uuml_thys_ver01/

sed -i -E "s#/opt/chronam#${chronamDir}#" ${chronamDir}/settings.py

django-admin.py load_batch ${chronamDir}/data/batches/batch_uuml_thys_ver01
