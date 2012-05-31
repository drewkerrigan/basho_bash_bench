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
	method="PUT"
	header_date=$(date +'%a, %d %b %Y %T %Z')
	filenumber=$(($RANDOM % 100))
	filename=`(echo "$RANDOM" | md5sum | head -c 12)`
	path="test/$filename"
	auth_string="$method\n\napplication/octet-stream\n$header_date\n/$path"
	hash_code=`echo -n -e "$auth_string" | openssl dgst -binary -sha1 -hmac $moss_secret_key | base64`
	auth_header="AWS $moss_access_key:$hash_code"
	command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"Authorization: $auth_header\" -H \"Content-Type: application/octet-stream\" -H \"Date: $header_date\" -XPUT --proxy1.0 $cs_proxy_host $cs_host/$path -T ./$common_file_location/$filenumber"
	
	if [ "$DEBUG" != TRUE ]
	then
		result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "Authorization: $auth_header" -H "Content-Type: application/octet-stream" -H "Date: $header_date" -XPUT --proxy1.0 $cs_proxy_host $cs_host/$path -T ./$common_file_location/$filenumber`
    	echo $result >> $results_dir/stats.txt
    	echo "$filename" >> $results_dir/filelist.txt
    	
    	if [[ "$result" != *"status:200"* ]] && [[ "$result" != *"status:204"* ]]
    	then
    		print_exception "Bad Status: $result from curl command: $command"
    	fi
    else
		print_debug "Curl command:"
		print_debug $command
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
		method="GET"
		header_date=$(date +'%a, %d %b %Y %T %Z')
	    line=$(($RANDOM % $filecount + 1))
	    filename=$(awk "NR==$line" ./filelist.txt)
	    output_filename=`(echo "$RANDOM" | md5sum | head -c 12)`
	    path="test/$filename"
	    auth_string="$method\n\napplication/octet-stream\n$header_date\n/$path"
	    hash_code=`echo -n -e "$auth_string" | openssl dgst -binary -sha1 -hmac $moss_secret_key | base64`
	    auth_header="AWS $moss_access_key:$hash_code"
	    command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"Authorization: $auth_header\" -H \"Content-Type: application/octet-stream\" -H \"Date: $header_date\" -XGET --proxy1.0 $cs_proxy_host $cs_host/$path"
	    
	    if [ "$DEBUG" != TRUE ]
		then
			result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "Authorization: $auth_header" -H "Content-Type: application/octet-stream" -H "Date: $header_date" -XGET --proxy1.0 $cs_proxy_host $cs_host/$path`
	    	echo $result >> $results_dir/stats.txt
	    	
	    	if [[ "$result" != *"status:200"* ]] && [[ "$result" != *"status:204"* ]]
	    	then
	    		print_exception "Bad Status: $result from curl command: $command"
	    	fi
	    else
			print_debug "Curl command:"
			print_debug $command
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
		method="PUT"
		header_date=$(date +'%a, %d %b %Y %T %Z')
	    filenumber=$(($RANDOM % 100))
	    line=$(($RANDOM % $filecount + 1))
	    filename=$(awk "NR==$line" ./filelist.txt)
	    path="test/$filename"
	    auth_string="$method\n\napplication/octet-stream\n$header_date\n/$path"
	    hash_code=`echo -n -e "$auth_string" | openssl dgst -binary -sha1 -hmac $moss_secret_key | base64`
	    auth_header="AWS $moss_access_key:$hash_code"
	    command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"Authorization: $auth_header\" -H \"Content-Type: application/octet-stream\" -H \"Date: $header_date\" -XPUT --proxy1.0 $cs_proxy_host $cs_host/$path -T ./$common_file_location/$filenumber"
	    
	    if [ "$DEBUG" != TRUE ]
		then
			result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "Authorization: $auth_header" -H "Content-Type: application/octet-stream" -H "Date: $header_date" -XPUT --proxy1.0 $cs_proxy_host $cs_host/$path -T ./$common_file_location/$filenumber`
	    	echo $result >> $results_dir/stats.txt
	    	
	    	if [[ "$result" != *"status:200"* ]] && [[ "$result" != *"status:204"* ]]
	    	then
	    		print_exception "Bad Status: $result from curl command: $command"
	    	fi
	    else
			print_debug "Curl command:"
			print_debug $command
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
		method="DELETE"
		header_date=$(date +'%a, %d %b %Y %T %Z')
	    line=$(($RANDOM % $filecount + 1))
	    filename=$(awk "NR==$line" ./filelist.txt)
	    path="test/$filename"
	    auth_string="$method\n\napplication/octet-stream\n$header_date\n/$path"
	    hash_code=`echo -n -e "$auth_string" | openssl dgst -binary -sha1 -hmac $moss_secret_key | base64`
	    auth_header="AWS $moss_access_key:$hash_code"
	    command="curl -o /dev/null -w \"time:%{time_total},status:%{http_code}\" -k -s -H \"Authorization: $auth_header\" -H \"Content-Type: application/octet-stream\" -H \"Date: $header_date\" -XDELETE --proxy1.0 $cs_proxy_host $cs_host/$path"
	    
	    
	    if [ "$DEBUG" != TRUE ]
		then
			sed -i "$(($line))d" ./filelist.txt
			result=`curl -o /dev/null -w "time:%{time_total},status:%{http_code}" -k -s -H "Authorization: $auth_header" -H "Content-Type: application/octet-stream" -H "Date: $header_date" -XDELETE --proxy1.0 $cs_proxy_host $cs_host/$path`
	    	echo $result >> $results_dir/stats.txt
	    	
	    	if [[ "$result" != *"status:200"* ]] && [[ "$result" != *"status:204"* ]]
	    	then
	    		print_exception "Bad Status: $result from curl command: $command"
	    	fi
	    else
			print_debug "Curl command:"
			print_debug $command
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