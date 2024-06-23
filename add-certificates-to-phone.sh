#!/bin/sh
set -e -u

# FIXME: make this script work when not executed from current directory

is_wsl() {
	test -r /proc/version && grep -iF Microsoft /proc/version >/dev/null 2>&1
}

if is_wsl
then
	BIN_SUFFIX=.exe
else
	BIN_SUFFIX=
fi

for _cmd in ADB=adb CERTUTIL=certutil SED=sed
do
  if command -v "${_cmd#*=}${BIN_SUFFIX-}" >/dev/null 2>&1
  then
    readonly "${_cmd%%=*}=${_cmd#*=}${BIN_SUFFIX-}"
  else
    printf '%s: command not found\n' "${_cmd#*=}" >&2
    exit 1
  fi
done
unset -v _cmd

GREEN='\033[32m'
RESET='\033[00;00m'
log() {
    printf "${GREEN}%s${RESET}\n" "$*"
}

usage() {
    cat <<-EOF >&2
	Usage: ${0} [ -r dir | -d | -h ]

	-r (dir) Enter the NSS DB root directory (usually /data/b2g/mozilla)
	         Some phones may be different.
	         For more information, please visit: https://github.com/openGiraffes/b2g-certificates
	-d Use default directory (/data/b2g/mozilla)
	-h Output this help.
	EOF
	exit 1
}

ROOT_DIR_DB=

while getopts 'dhr:' option
do
	case ${option}
	in
		(d) ROOT_DIR_DB=/data/b2g/mozilla ;;
		(r) ROOT_DIR_DB=${OPTARG} ;;
		(h) usage ;;
	esac
done
unset -v option

CERT_DIR=certs
CERT=cert9.db
KEY=key4.db
PKCS11=pkcs11.txt
readonly CERT_DIR CERT KEY PKCS11

test "$(${ADB:?} shell "test -r '${ROOT_DIR_DB}'; echo \$?")" -eq 0 || {
	printf 'Cannot access %s. Is your device rooted?\n' "${ROOT_DIR_DB}" >&2
	exit 1
}

DB_NAME=$(${ADB:?} shell "cat '${ROOT_DIR_DB}/profiles.ini'" \
	| awk '
	  BEGIN { RS = "\r?\n" }

	  /^\[/ {
		  if (default) exit
		  default = 0
		  name = ""
	  }
	  /^(Default|Path)=/ {
		  t = substr($0, index($0, "=")+1)
		  sub(/\r$/, "", t)
		  if (/^Path=/) { path = t }
		  else if (/^Default=/) { default = int(t) }
	  }
	  END {
		  if (default) {
			  print path
		  } else {
			  exit 1
		  }
	  }')

test -n "${DB_NAME}" || {
	echo "Profile directory does not exist. Please start the b2g process at
least once before running this script." >&2
	exit 1
}

DB_DIR=${ROOT_DIR_DB:?}/${DB_NAME:?}

${ADB:?} shell "test -d '${DB_DIR}'" || {
	printf 'Profile directory %s does not exist.\n' "${DB_DIR}" >&2
	exit 1
}

# cleanup
rm -f "./${CERT}"
rm -f "./${KEY}"
rm -f "./${PKCS11}"

# pull files from phone
log "getting ${CERT}"
${ADB:?} pull "${DB_DIR:?}/${CERT}" .
log "getting ${KEY}"
${ADB:?} pull "${DB_DIR:?}/${KEY}" .
log "getting ${PKCS11}"
${ADB:?} pull "${DB_DIR:?}/${PKCS11}" .

# clear password and add certificates
{ echo;echo; } >.nsspw.txt

${CERTUTIL:?} -d 'sql:.' -N -f .nsspw.txt -@ .nsspw.txt >/dev/null

log 'adding certificates...'
for f in "${CERT_DIR}"/*
do
	log "- ${f}"
	${CERTUTIL:?} -d 'sql:.' -A -n "${f##*/}" -t 'C,C,TC' -f .nsspw.txt <"${f}"
done
rm -f .nsspw.txt
log 'updating certificates on phone...'

# push files to phone
log 'stopping b2g'
${ADB:?} shell stop b2g

log "copying ${CERT}"
${ADB:?} push ./${CERT} ${DB_DIR}/${CERT}
log "copying ${KEY}"
${ADB:?} push ./${KEY} ${DB_DIR}/${KEY}
log "copying ${PKCS11}"
${ADB:?} push ./${PKCS11} ${DB_DIR}/${PKCS11}

log 'starting b2g'
${ADB:?} shell start b2g

log 'finished.'
