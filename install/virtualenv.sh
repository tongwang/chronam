#!/usr/bin/env bash

cd ${chronamDir}

if [ ! -d "${chronamDir}/ENV" ]
then
log "create vritual environment for chronam"
  virtualenv ENV >> $LOG_FILE
fi

source ${chronamDir}/ENV/bin/activate >> $LOG_FILE
#export PYTHONPATH=/opt
export PYTHONPATH=`dirname ${chronamDir}`

log "install python modules for chronam"
pip install -U distribute >> $LOG_FILE
pip install  --allow-external PIL --allow-unverified PIL -r requirements.pip >> $LOG_FILE

log "create chronam data directories"
mkdir -p ${chronamDir}/data/batches >> $LOG_FILE
mkdir -p ${chronamDir}/data/cache >> $LOG_FILE
mkdir -p ${chronamDir}/data/bib >> $LOG_FILE
