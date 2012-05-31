#!/bin/bash

source $(dirname $0)/functions.sh

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
RESULTSDIR=""

#----------------------------------------------------------------------
# populate values from command line options and validate
#----------------------------------------------------------------------
while getopts ":c:p:s:t:w:o:r:d" opt; do
  case $opt in
    c) CONFIG="${OPTARG}";;
    p) PRODUCT="${OPTARG}";;
    s) SIZE="${OPTARG}";;
    t) TIME="${OPTARG}";;
    w) WORKERS="${OPTARG}";;
    o) OPERATION="${OPTARG}";;
    r) RESULTSDIR="${OPTARG}";;
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
# include / create required files
#----------------------------------------------------------------------
source $(dirname $0)/$CONFIG
source $(dirname $0)/drivers/$PRODUCT.sh

if [ "$RESULTSDIR" == "" ]
then
	results_dir="./results/$PRODUCT-$SIZE-mb-$TIME-min-$WORKERS-wr-$OPERATION"
else
	results_dir="$RESULTSDIR"
fi

if [ -e "$results_dir" ]
then
	echo "found $results_dir"
else
	echo "creating $results_dir"
	mkdir $results_dir
	mkdir $results_dir/backup
fi

#----------------------------------------------------------------------
# cleanup or leave old data
#----------------------------------------------------------------------
if [ -e "$results_dir/stats.txt" ] && [ "$RESULTSDIR" == "" ]
then
	mv $results_dir/stats.txt{,.bak}
fi

if [ "$OPERATION" == "create" ]
then
	if [ -e "$results_dir/filelist.txt" ] && [ "$RESULTSDIR" == "" ]
	then
		mv $results_dir/filelist.txt{,.bak}
	fi
else
	if [ -e "filelist.txt" ]
	then
		echo "filelist.txt will be used for this $OPERATION operation"
	else
		print_exception "a populated filelist.txt is required for the $OPERATION operation"
		exit 1
	fi
fi

#----------------------------------------------------------------------
# spawn worker threads if there is more than one
#----------------------------------------------------------------------
if [ "$WORKERS" -gt 1 ]
then
	if [ -e "$results_dir/worker_output1.txt" ]
	then
		echo "moving files to backup"
		mv $results_dir/worker_output* $results_dir/backup/
	fi
	
	d=""
	if [ "$DEBUG" == TRUE ]; then d="-d"; fi
	
	for (( i=1; i<=$WORKERS; i++ ))
	do
		print_debug "Starting worker $i"
		$0 -c $CONFIG -p $PRODUCT -s $SIZE -t $TIME -w 1 -o $OPERATION -r $results_dir $d &> $results_dir/worker_output$i.txt & 
	done
	
	exit 0
fi

#----------------------------------------------------------------------
# run the test
#----------------------------------------------------------------------
nowtime=$(date '+%s')
endtime=$((nowtime + duration))

print_debug "Nowtime: $nowtime, Endtime: $endtime "

op_init

echo "Starting test..."
while [ $nowtime -lt $endtime ]
do
  op_$OPERATION
  
  if [ "$DEBUG" == TRUE ]; then break; fi
  
  nowtime=$(date '+%s')
done

#----------------------------------------------------------------------
# move filelist.txt to the base directory for future use
#----------------------------------------------------------------------

if [ "$OPERATION" == "create" ]
then
	if [ -e "filelist.txt" ] && [ "$RESULTSDIR" == "" ]; then mv filelist.txt{,.bak}; fi
	if [ -e "$results_dir/filelist.txt" ]; then cp $results_dir/filelist.txt filelist.txt; fi
fi

exit 0