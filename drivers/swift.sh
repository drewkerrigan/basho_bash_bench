#=== FUNCTION ================================================================
# NAME: op_init
# DESCRIPTION: Initialize the connection for this driver
# PARAMETER 1: ---
#=============================================================================
function op_init() {
	print_debug "Initializing"
}

#=== FUNCTION ================================================================
# NAME: op_create
# DESCRIPTION: run a single create call
# PARAMETER 1: ---
#=============================================================================
function op_create() {
	print_debug "Enter op_create()"
	filenumber=$(($RANDOM % 100))
	filename=`(echo "$RANDOM" | md5sum | head -c 12)`

	if [ "$DEBUG" != TRUE ]
	then
		result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -H "Content-Type: application/junk" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber`
    	echo $result >> $results_dir/stats.txt
    	echo "$filename" >> $results_dir/filelist.txt
    else
		print_debug "Curl command:"
		print_debug "curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -H \"Content-Type: application/junk\" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber"
    fi
}

#=== FUNCTION ================================================================
# NAME: op_read
# DESCRIPTION: run a single read call
# PARAMETER 1: ---
#=============================================================================
function op_read() {
	print_debug "Enter op_read()"
	filecount=$(wc -l ./filelist.txt | sed -s "s/ .\/filelist.txt//")
	line=$(($RANDOM % $filecount + 1))
	filename=$(awk "NR==$line" ./filelist.txt)

    if [ "$DEBUG" != TRUE ]
	then
		result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -H "Content-Type: application/junk" -XGET $swift_host/v1/AUTH_system/testdemo/$filename`
    	echo $result >> $results_dir/stats.txt
    else
		print_debug "Curl command:"
		print_debug "curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -H \"Content-Type: application/junk\" -XGET $swift_host/v1/AUTH_system/testdemo/$filename"
    fi
}

#=== FUNCTION ================================================================
# NAME: op_update
# DESCRIPTION: run a single update call
# PARAMETER 1: ---
#=============================================================================
function op_update() {
	print_debug "Enter op_update()"
	filenumber=$(($RANDOM % 100))
	filecount=$(wc -l ./filelist.txt | sed -s "s/ .\/filelist.txt//")
	line=$(($RANDOM % $filecount + 1))
	filename=$(awk "NR==$line" ./filelist.txt)
    
    if [ "$DEBUG" != TRUE ]
	then
		result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -H "Content-Type: application/junk" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber`
    	echo $result >> $results_dir/stats.txt
    else
		print_debug "Curl command:"
		print_debug "curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -H \"Content-Type: application/junk\" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber"
    fi
}

#=== FUNCTION ================================================================
# NAME: op_delete
# DESCRIPTION: run a single delete call
# PARAMETER 1: ---
#=============================================================================
function op_delete() {
	print_debug "Enter op_delete()"
	filecount=$(wc -l ./filelist.txt | sed -s "s/ .\/filelist.txt//")
	line=$(($RANDOM % $filecount + 1))
	filename=$(awk "NR==$line" ./filelist.txt)
    
    if [ "$DEBUG" != TRUE ]
	then
		result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -XDELETE $swift_host/v1/AUTH_system/testdemo/$filename`
    	echo $result >> $results_dir/stats.txt
    	sed -i "$(($line))d" ./filelist.txt
    else
		print_debug "Curl command:"
		print_debug "curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -XDELETE $swift_host/v1/AUTH_system/testdemo/$filename"
    fi
}

#=== FUNCTION ================================================================
# NAME: op_mix
# DESCRIPTION: randomly run one of the other operations
# PARAMETER 1: ---
#=============================================================================
function op_mix() {
	if [ "$DEBUG" == TRUE ];
	then
    	op_create
    	op_read
    	op_update
    	op_delete
    fi

	test_type=$(($RANDOM % 20))

	if [ $test_type -lt 2 ]
	then
		op_create
	elif [ $test_type -lt 18 ]
	then
		op_read
	elif [ $test_type -lt 19 ]
	then
		op_update
	else
		op_delete
	fi
}