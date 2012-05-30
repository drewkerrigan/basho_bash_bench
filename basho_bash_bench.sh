#!/bin/bash

#=== FUNCTION ================================================================
# NAME: print_usage
# DESCRIPTION: Display usage information for this script.
# PARAMETER 1: script name
#=============================================================================
function print_usage() {
cat <<- EOT
Run a benchmarking test given a product and options.

usage : $1 -c <config file> -p <product> -s <size> -t <time> -w <workers> -o <operation> [-d]

example usage : $1 -c basho_bash_bench.cfg -p cs -s 2 -t 60 -w 1 -o create
    (equivalent of old curl_test_cs_2MB_1HR_1WR_CREATE)
		
-c <config: location of config file> 
-p <product: cs || cassandra || swift>
-s <size: (in MB) 2 | 24 | 136>
-t <time: (in min) 30 | 60 | 120>
-w <workers: 1 | 10 | 20 | 100>
-o <operation: create | read | update | delete | mix | create_fail | create_fail2 | create_fail3 | mix_fail | mix_fail2 | mix_fail3 | update_fail | delete_fail>
-d (debug, only prints diagnostic information about what will be run)
EOT
}

#=== FUNCTION ================================================================
# NAME: print_debug
# DESCRIPTION: used to print debug information
# PARAMETER 1: message
#=============================================================================
function print_debug() {
	if [ "$DEBUG" == TRUE ]; 
	then 
		echo "**DEBUG**: $1"; 
	fi
}

#----------------------------------------------------------------------
# initialize
#----------------------------------------------------------------------
CONFIG=""
DEBUG=""
PRODUCT=""
SIZE=""
TIME=""
WORKERS=""
OPERATION=""

#----------------------------------------------------------------------
# populate values from command line options and validate
#----------------------------------------------------------------------
while getopts ":c:p:s:t:w:o:d" opt; do
  case $opt in
    c) CONFIG="${OPTARG}";;
    p) PRODUCT="${OPTARG}";;
    s) SIZE="${OPTARG}";;
    t) TIME="${OPTARG}";;
    w) WORKERS="${OPTARG}";;
    o) OPERATION="${OPTARG}";;
    d) DEBUG=TRUE;;
  esac
done

if [ "$CONFIG" == "" ] || 
   [ "$PRODUCT" == "" ] ||
   [ "$SIZE" == "" ] ||
   [ "$TIME" == "" ] ||
   [ "$WORKERS" == "" ] ||
   [ "$OPERATION" == "" ]
then
	print_usage $0
	exit 1
fi

duration=$(($TIME * 60))

print_debug "driver= drivers/$PRODUCT.sh"
print_debug "size= $SIZE MB"
print_debug "time= $duration seconds"
print_debug "number of workers= $WORKERS"
print_debug "operation= $OPERATION"

#----------------------------------------------------------------------
# include required files
#----------------------------------------------------------------------
source $(dirname $0)/$CONFIG
source $(dirname $0)/drivers/$PRODUCT.sh

#----------------------------------------------------------------------
# run the test
#----------------------------------------------------------------------

if [ "$WORKERS" -gt 1 ]
then
	if [ -e "worker_output1.txt" ]
	then
		echo "moving files to backup"
		mv worker_output* backup/
	fi
	
	d=""
	if [ "$DEBUG" == TRUE ]; then d="-d"; fi
	
	for (( i=1; i<=$WORKERS; i++ ))
	do
		print_debug "Starting worker $i"
		./$0 -c $CONFIG -p $PRODUCT -s $SIZE -t $TIME -w 1 -o $OPERATION $d &> worker_output$i.txt & 
	done
	
	exit 0
fi

nowtime=$(date '+%s')
endtime=$((nowtime + duration))

print_debug "Nowtime: $nowtime, Endtime: $endtime "

init

echo "Starting test..."
while [ $nowtime -lt $endtime ]
do
  $OPERATION
  
  if [ "$DEBUG" == TRUE ]; then break; fi
  
  nowtime=$(date '+%s')
done


exit 0