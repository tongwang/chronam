#1/usr/bin/env bash

function realpath {
  perl -MCwd -e 'print Cwd::realpath ($ARGV[0]), qq<\n>' $0
}

LOG_FILE=install.log

function log() {
  echo $1 >> /dev/stdout
  echo $1 >> ${LOG_FILE}
}

fullScriptPath=`realpath $0`
installDir=`dirname $fullScriptPath`
chronamDir=`dirname $installDir`

#we 'run' the other scripts by sourcing them. That way we can easily share variables without having to export them
source ${installDir}/dependencies.sh
source ${installDir}/solr.sh
#source ${installDir}/apache.sh
source ${installDir}/virtualenv.sh
source ${installDir}/mysql.sh
source ${installDir}/django.sh
