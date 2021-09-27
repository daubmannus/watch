#!/bin/bash

####################################################
# GLOBAL FUNCTIONS
####################################################

throw() {
	ERR=$1
	MSG="$2"
	[ -z MSG ] && MSG='unknown'
	[ -z ERRCODE ] && ERRCODE=254
	echo -e "error: $MSG" 1>&2
	exit $ERR
}

warn() {
	echo "WARNING: $1" 1>&2
}

log() {
    DATE_STR="$(date -d@$(date +%s) +'%Y-%m-%d %H:%M:%S (%:z)')"
    echo $DATE_STR - "$@"
}

