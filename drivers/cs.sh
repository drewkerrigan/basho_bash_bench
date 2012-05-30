#=== FUNCTION ================================================================
# NAME: init
# DESCRIPTION: Initialize the connection for this driver
# PARAMETER 1: ---
#=============================================================================
function init() {
	print_debug "Initializing"
}

#=== FUNCTION ================================================================
# NAME: create
# DESCRIPTION: run a single create call
# PARAMETER 1: ---
#=============================================================================
function create() {
	print_debug "Enter create()"
	method="PUT"
	header_date=$(date +'%a, %d %b %Y %T %Z')
	filenumber=$(($RANDOM % 100))
	filename=`(echo "$RANDOM" | md5sum | head -c 12)`
	path="test/$filename"	
	auth_string="$method\n\napplication/octet-stream\n$header_date\n$path"
	hash_code=`echo -n -e "$auth_string" | openssl dgst -binary -sha1 -hmac $moss_secret_key | base64`
	auth_header="AWS $moss_access_key:$hash_code"

	command="curl -o /dev/null -w \"time: \"%{time_total}\" status: \"%{http_code} -k -s -H \"Authorization: $auth_header\" -H \"Content-Type: application/octet-stream\" -H \"Date: $header_date\" -XPUT --proxy1.0 $cs_proxy_host $cs_host/$path -T ./files/$filenumber"
	
	print_debug "Curl command:";
	print_debug "$command";
	
	if [ "$DEBUG" != TRUE ];
	then
		result=`$command`
		echo $result  >> stats.txt
  		echo "$filename" >> filelist.txt
	fi
}