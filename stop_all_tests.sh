#!/bin/bash
kill `ps -ef | grep basho_bash_bench | grep -v grep | awk '{print $2}'`