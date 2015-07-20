#1/usr/bin/env bash

cd ${chronamDir}

log "create vritual environment for chronam"
virtualenv ENV
source ${chronamDir}/ENV/bin/activate
export PYTHONPATH=/opt

log "install python modules for chronam"
pip install -U distribute
pip install  --allow-external PIL --allow-unverified PIL -r requirements.pip

log "create chronam data directories"
mkdir -p ${chronamDir}/data/batches
mkdir -p ${chronamDir}/data/cache
mkdir -p ${chronamDir}/data/bib
