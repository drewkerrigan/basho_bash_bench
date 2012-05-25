#!/bin/bash
CONFIG=""
DEBUG=""

function print_usage() {
	echo "Usage: $1 -c basho_bash_bench.cfg [-d]\n"
	echo "Flags: -c <location of config file> -d (debug)"
}

while getopts ":c:d" opt; do
  case $opt in
    c) CONFIG="${OPTARG}";;
    d) DEBUG=TRUE;;
  esac
done


if [ "$CONFIG" == "" ]
then
	print_usage $0
	exit 1
fi

if [ "$DEBUG" == TRUE ]
then
	echo "debug, yeaaaa"
fi

source $CONFIG

exit 0