#!/bin/bash

####################################################
# second version
#
# depends on watchdirsw.exe
# and
# _global.sh with global functions
####################################################


LST_FN='.wlst'

SCRIPTS_PATH='watch_scripts'
SCRIPTS_PATH=$(readlink -e "$SCRIPTS_PATH")

source "$SCRIPTS_PATH/_global.sh"

# cleanup() { 
	# for dir in "${DIRS[@]}"; do
		# cd "$dir"
		# rm -f "$LST_FN" "$LST_FN".bkp
		# cd - 1>/dev/null
	# done
# }

ctrl_c() { 
	log "======= STOPPED BY USER (^C) ======="
	[ -v $LOG_REPEAT ] && echo "STOPPED BY USER (^C)" 1>&2
	exit 0
}

trap ctrl_c SIGINT

##########################################
files_in_dir() { 
	ls -p | grep -v /
}

mklst() { 
	# NB: for current dir
	
	# printf "mklst "
	# pwd
	
	[ -f "$LST_FN" ] \
		&& mv "$LST_FN" "$LST_FN".bkp
	
	printf '' >"$LST_FN"
	[ -f "$LST_FN".bkp ] \
		|| cp "$LST_FN" "$LST_FN".bkp

	while IFS= read -r filename; do
		stat --format="%n/%s/%Y" "$filename" >>"$LST_FN"
	done < <(files_in_dir)
	
}

script_name() { 
	# get key by value
	for key in ${!DIRS[@]}; do
		[[ "$1" == "${DIRS[$key]}" ]] \
			&& echo "$key"
	done
}

process_new_file() { 
	script=$(script_name "$changed_dir")
	log "new ($1) -> [$script]"
	"$SCRIPTS_PATH/$script" "$1"
	# "$SCRIPTS_PATH/$(script_name "$changed_dir")" "$1"
}

process_dir() { 
# NB: run it only in subshell!
	
	[ -z "$1" ] && throw "no dir specified to process"
	cd "$1"
	
	# update .lst
	mklst
	
	diffs=$(diff "$LST_FN".bkp "$LST_FN" 2>/dev/null)
	
	[ -z "$diffs" ] && return
	log ".lst changed [$1]"
	
	while IFS= read -r diff_line; do
		# echo "$diff_line"
		[[ "$diff_line" =~ ^'> ' ]] \
			&& diff_line="${diff_line#> }" && process_new_file "${diff_line%%/*}"
	done < <(printf '%s\n' "$diffs")
}


##########################################
# MAIN

#### init dirs
echo "initializing:"
for key in ${!DIRS[@]}; do
	echo "[$key] -> ${DIRS[$key]}"
	[ -d "${DIRS[$key]}" ] \
		|| throw 1 "dir doesn't exist (${DIRS[$key]})"
	[ -s "$SCRIPTS_PATH/$key" ] \
		|| throw 2 "script doesn't exist ($SCRIPTS_PATH/$key)"
done

#### main loop (^c to exit)
log "======= WATCH SCRIPT STARTED ======="
while true; do
	# loop for all the dirs, 
	# to process changed while was in idle
	for dir in "${DIRS[@]}"; do
		( process_dir "$dir" )
	done

	echo "watching... (press ^C for exit)"
	#### run binary, wait
	changed_dir=$("$WATCH_BIN" "${DIRS[@]}")
	
	log "$(basename $WATCH_BIN): [$changed_dir]"
	( process_dir "$changed_dir" )
	
done
