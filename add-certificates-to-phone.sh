#!/bin/bash

function log
{
    GREEN="\E[32m"
    RESET="\033[00;00m"
    echo -e "${GREEN}$1${RESET}"
}

usage() {
  echo "Usage: ${0} [-r] (dir) | [-d] | [-h]" 1>&2
  echo ""
  echo "-r (dir) Enter the NSS DB root directory ( Such as Nokia, enter /data/b2g/mozilla )"
  echo "         Some phones may be different."
  echo "         For more information, please visit: https://github.com/openGiraffes/b2g-certificates"
  echo "-d Use default directory (/data/b2g/mozilla)"
  echo "-h Output this help."
  exit 1
}

ROOT_DIR_DB=

while getopts "dhr:" options
do
    case ${options} in
        d) ROOT_DIR_DB=/data/b2g/mozilla;;
        r) ROOT_DIR_DB=$OPTARG;;
        h) usage;;
    esac
done

CERT_DIR=certs
CERT=cert9.db
KEY=key4.db
PKCS11=pkcs11.txt
DB_DIR=`adb shell "ls -d ${ROOT_DIR_DB}/*.default 2>/dev/null" | sed "s/default.*$/default/g"`

if [ "${DB_DIR}" = "" ]; then
  echo "Profile directory does not exists. Please start the b2g process at
least once before running this script."
  exit 1
fi

# cleanup
rm -f ./$CERT
rm -f ./$KEY
rm -f ./$PKCS11

# pull files from phone
log "getting ${CERT}"
adb pull ${DB_DIR}/${CERT} .
log "getting ${KEY}"
adb pull ${DB_DIR}/${KEY} .
log "getting ${PKCS11}"
adb pull ${DB_DIR}/${PKCS11} .

# clear password and add certificates
log "set password (hit enter twice to set an empty password)"
certutil -d 'sql:.' -N

log "adding certificats"
for i in ${CERT_DIR}/*
do
  log "Adding certificate $i"
  certutil -d 'sql:.' -A -n "`basename $i`" -t "C,C,TC" -i $i
done

# push files to phone
log "stopping b2g"
adb shell stop b2g

log "copying ${CERT}"
adb push ./${CERT} ${DB_DIR}/${CERT}
log "copying ${KEY}"
adb push ./${KEY} ${DB_DIR}/${KEY}
log "copying ${PKCS11}"
adb push ./${PKCS11} ${DB_DIR}/${PKCS11}

log "starting b2g"
adb shell start b2g

log "Finished."
