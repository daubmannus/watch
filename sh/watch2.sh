#!/bin/bash

####################################################
# second version
#
# depends on watchdirsw.exe
# and
# _global.sh with global functions
####################################################
LST_FN='.wlst'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_PATH="$SCRIPT_DIR/watch_scripts"
SCRIPTS_PATH=$(readlink -e "$SCRIPTS_PATH")

source "$SCRIPTS_PATH/_global.sh"

##########################################
# EXIT_CODE=0
# trap "exit $EXIT_CODE" SIGTERM
trap ctrl_c SIGINT

ctrl_c() { 
	log "======= STOPPED BY USER (^C) ======="
	[ -v $LOG_REPEAT ] && echo "STOPPED BY USER (^C)" 1>&2
	exit 0
}
##########################################

files_in_dir() { 
	ls -p | grep -v /
}

mklst() { 
	# NB: for current dir
	
	# printf " mklst"
	# pwd
	
	printf '' >"$LST_FN"

	while IFS= read -r filename; do
		[ -r "$filename" ] \
			&& stat --format="%n/%s/%Y" "$filename" >>"$LST_FN" 
	done < <(files_in_dir)
	
}

bkplst() { 
	[ -z "$1" ] && set -- .
	
	[ -f "$1"/"$LST_FN" ] \
		&& mv "$1"/"$LST_FN" "$1"/"$LST_FN".bkp
}

script_name() { 
	# get key by value
	for key in ${!DIRS[@]}; do
		[[ "$1" == "${DIRS[$key]}" ]] \
			&& echo "$key"
	done
}

process_new_file() { 
	script=$(script_name "$dir_to_process")
	[ -v $VERBOSE ] || log "new ($1) -> [$script]"
	"$SCRIPTS_PATH/$script" "$1" \
		|| warn "SCRIPT FAILED ($script: $?)"
}

process_dir() { 
	[ -z "$1" ] &&  set -- .
	
	[ $(script_name "$1") == "$WAKE_KEY" ] && return 0
	
	cd "$1"
	
	# update .lst
	mklst
	
	[ -f "$LST_FN".bkp ] \
		|| printf '' >"$LST_FN".bkp
	
	diffs=$(diff "$LST_FN".bkp "$LST_FN" 2>/dev/null)
	
	[ -z "$diffs" ] && return 0
	[ -v $VERBOSE ] || log ".lst changed [$1]"
	
	# echo "
# $diffs
	# "
	
	while IFS= read -r diff_line; do
		# echo "$diff_line"
		[[ "$diff_line" =~ ^'> ' ]] \
			&& diff_line="${diff_line#> }" && process_new_file "${diff_line%%/*}"
	done < <(printf '%s\n' "$diffs")
	
	bkplst
	
	return 1
}

set_watcher_break() {
	( 
		sleep "$1"
		# __path_to_first_lst="$( printf %s\\n "${DIRS[@]}" | cut -d$'\n' -f1 )/$LST_FN"
		touch "${DIRS[$WAKE_KEY]}"/killme
		rm "${DIRS[$WAKE_KEY]}"/killme
		log break watcher
	) &
}

##########################################
# MAIN

#### init dirs
[ -v $VERBOSE ] || echo "initializing:"
for key in ${!DIRS[@]}; do
	[ -v $VERBOSE ] || echo "[$key] -> ${DIRS[$key]}"
	[ -d "${DIRS[$key]}" ] \
		|| throw 1 "dir doesn't exist (${DIRS[$key]})"
	[ -s "$SCRIPTS_PATH/$key" ] \
		|| [ "$key" == "$WAKE_KEY" ] \
		|| throw 2 "script doesn't exist ($SCRIPTS_PATH/$key)"
done

#### main loop (^c to exit)
log "===== WATCH SCRIPT (v2) STARTED ===="
[ -v $LOG_REPEAT ] && echo "watching... (press ^C for exit)"
while true; do
	# loop for all the dirs, 
	# to process changed while was in idle or busy
		for dir_to_process in "${DIRS[@]}"; do
			( process_dir "$dir_to_process" )
		done
	
	
	## break watcher after ... time
	set_watcher_break "1h"

	#### run binary, wait
	[ -v $VERBOSE ] || log "...$WATCH_BIN is watching..." 
	dir_to_process=$("$WATCH_BIN" "${DIRS[@]}")
	
	if [ -d "$dir_to_process" ]; then
		[ -v $VERBOSE ] || log "$(basename $WATCH_BIN): [$dir_to_process]"
		( process_dir "$dir_to_process" )
	else
		throw "can't read dir to process ($dir_to_process)"
	fi
	
done
