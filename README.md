# basho-bash-bench

A bash based driver for simple benchmarking tests, runs a benchmarking test given a product and options.

## Usage

./basho_bash_bench.sh -c <config file> -p <product> -s <size> -t <time> -w <workers> -o <operation> [-d]

example usage : ./basho_bash_bench.sh -c basho_bash_bench.cfg -p cs -s 2 -t 60 -w 1 -o create
    (equivalent of old curl_test_cs_2MB_1HR_1WR_CREATE)
		
## Options

* -c (config: location of config file)
* -p (product: cs | cassandra | swift)
* -s (size: (in MB) 2 | 24 | 136)
* -t (time: (in min) 30 | 60 | 120)
* -w (workers: 1 | 10 | 20 | 100)
* -o (operation: create | read | update | delete | mix)
* -d (debug, only prints diagnostic information about what will be run)