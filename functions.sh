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
-p <product: cs | cassandra | swift>
-s <size: (in MB) 2 | 24 | 136>
-t <time: (in min) 30 | 60 | 120>
-w <workers: 1 | 10 | 20 | 100>
-o <operation: create | read | update | delete | mix>
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

#=== FUNCTION ================================================================
# NAME: print_exception
# DESCRIPTION: used to print exception information
# PARAMETER 1: message
#=============================================================================
function print_exception() {
	echo "**EXCEPTION**: $1"; 
}
