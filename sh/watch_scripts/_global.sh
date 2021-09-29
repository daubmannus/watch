#!/bin/bash

DIRS_ROOT='./test'

WATCH_BIN='watchdirsw.exe'

LOG_FILENAME='log/watch.log'
MD5_FILENAME='log/imp.md5'

LOG_REPEAT=1
#__NO_LOG=1

declare -A DIRS=(\
	[first]="$DIRS_ROOT"/'dir 1st' \
	[second]="$DIRS_ROOT"/'dir2nd' \
)
	# [report]="$DIRS_ROOT"/'report' \


# 2DO: switch
# cleaning daily at 00:00
# __clean_time='00'


DIRS_ROOT=$(readlink -e "$DIRS_ROOT")
LOG_FILENAME=$(readlink -e "$LOG_FILENAME")
MD5_FILENAME=$(readlink -e "$MD5_FILENAME")

####################################################
# GLOBAL FUNCTIONS
####################################################

throw() { 
	ERR=$1
	MSG="$2"
	[ -z "$1" ] && MSG='unknown' && ERR=254
	[ -z "$2" ] && MSG="$1" && ERR=100
	log "======= ERROR $ERR: $MSG ======="
	[ -v $LOG_REPEAT ] && echo -e "error ($ERR): $MSG" 1>&2
	exit $ERR
}

warn() { 
	echo "WARNING: $1" 1>&2
}

date_str() { 
	printf "$(date -d@$(date +%s) +'%Y-%m-%d %H:%M:%S (%:z)')"
}

log() { 
	msg="$(date_str) - $@"
	[ -v $LOG_REPEAT ] || echo $msg
	[ -v $__NO_LOG ] || return
	[ -z $LOG_FILENAME ] \
		&& __NO_LOG=1 throw 101 "no log file"
	echo "$msg" >> "$LOG_FILENAME" \
		|| __NO_LOG=1 throw 102 "can't write log ($LOG_FILENAME)"
}
