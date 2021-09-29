#!/bin/bash

DIRS_ROOT='P:/hot'

WATCH_BIN='watchdirsw.exe'

LOG_FILENAME='C:/log/watch.log'
MD5_FILENAME='C:/log/imp.md5'

# LOG_REPEAT=1
#__NO_LOG=1
# VERBOSE=1

WAKE_KEY="__wake"

declare -A DIRS=(\
	["$WAKE_KEY"]="$DIRS_ROOT"
	[report]="$DIRS_ROOT"/'report' \
	[OUT]="$DIRS_ROOT"/'OUT' \
	[imp_in]="$DIRS_ROOT"/'imp/in' \
	[imp_pre]="$DIRS_ROOT"/'imp/pre' \
	[imp_pre_prn_out]="$DIRS_ROOT"/'imp/pre/_prn/out' \
	[imp_pre_cut_out]="$DIRS_ROOT"/'imp/pre/_cut/out' \
	[bkp_src_by_md5]="$DIRS_ROOT"/'imp/done' \
)



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
	
	# export EXIT_CODE=$ERR
	kill 0
	# exit $ERR
}

warn() { 
	log "======= WARNING: $1 ======="
	[ -v $LOG_REPEAT ] && echo "WARNING: $1" 1>&2
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
