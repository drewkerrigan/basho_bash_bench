#=== FUNCTION ================================================================
# NAME: op_init
# DESCRIPTION: Initialize the connection for this driver
# PARAMETER 1: ---
#=============================================================================
function op_init() {
	print_debug "Initializing"
}

#=== FUNCTION ================================================================
# NAME: op_record_result
# DESCRIPTION: Records statistics and logs exceptions
# PARAMETER 1: string result
# PARAMETER 2: string curl command
#=============================================================================
function op_record_result() {
	result=$1
	command=$2
	
	echo $result >> $results_dir/stats.txt
	
	if [[ "$result" != *"status:200"* ]] && [[ "$result" != *"status:204"* ]] && [[ "$result" != *"status:201"* ]]
	then
		print_exception "Bad Status: $result from curl command: $command"
	fi
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
	
	command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -H \"Content-Type: application/junk\" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber"
	print_debug "Curl command: $command"

	if [ "$DEBUG" != TRUE ]
	then
		result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -H "Content-Type: application/junk" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber`
		op_record_result "$result" "$command"
    	echo "$filename" >> $results_dir/filelist.txt
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
	if [ $filecount -gt 1 ]
	then
		line=$(($RANDOM % $filecount + 1))
		filename=$(awk "NR==$line" ./filelist.txt)
		
		command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -H \"Content-Type: application/junk\" -XGET $swift_host/v1/AUTH_system/testdemo/$filename"
		print_debug "Curl command: $command"
	
	    if [ "$DEBUG" != TRUE ] && [ "$filename" != "" ]
		then
			result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -H "Content-Type: application/junk" -XGET $swift_host/v1/AUTH_system/testdemo/$filename`
	    	op_record_result "$result" "$command"
	    fi
	fi
}

#=== FUNCTION ================================================================
# NAME: op_update
# DESCRIPTION: run a single update call
# PARAMETER 1: ---
#=============================================================================
function op_update() {
	print_debug "Enter op_update()"
	filecount=$(wc -l ./filelist.txt | sed -s "s/ .\/filelist.txt//")
	if [ $filecount -gt 1 ]
	then
		filenumber=$(($RANDOM % 100))
		line=$(($RANDOM % $filecount + 1))
		filename=$(awk "NR==$line" ./filelist.txt)
		
		command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -H \"Content-Type: application/junk\" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber"
		print_debug "Curl command: $command"
	    
	    if [ "$DEBUG" != TRUE ] && [ "$filename" != "" ]
		then
			result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -H "Content-Type: application/junk" -XPUT $swift_host/v1/AUTH_system/testdemo/$filename -T ./$common_file_location/$filenumber`
	    	op_record_result "$result" "$command"
	    fi
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
	if [ $filecount -gt 1 ]
	then
		line=$(($RANDOM % $filecount + 1))
		filename=$(awk "NR==$line" ./filelist.txt)
		
		command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"X-Auth-Token: $swift_auth_token\" -XDELETE $swift_host/v1/AUTH_system/testdemo/$filename"
		print_debug "Curl command: $command"
	    
	    if [ "$DEBUG" != TRUE ] && [ "$filename" != "" ]
		then
			sed -i "$(($line))d" ./filelist.txt
			result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "X-Auth-Token: $swift_auth_token" -XDELETE $swift_host/v1/AUTH_system/testdemo/$filename`
			op_record_result "$result" "$command"
	    fi
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