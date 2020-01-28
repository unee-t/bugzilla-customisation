#!/bin/bash

# This script creates dependencies check the BZ Db
#
# We needs several variables that are maintained in different places:
#
# We needs several variables that are maintained in different places:
#	- Variables stored in the Travis CI "Settings":
#		n/a
#	- Variables stored in the aws-env.[stage] file
#		- STAGE
#		- BZDB_CHECK_HOST
#		- API_ACCESS_TOKEN

domain() {
	case $1 in
		dev)
			echo "DEVELOPMENT" >&2
			source aws-env.dev
			echo $BZDB_CHECK_HOST
			;;
		prod) 
			echo "PRODUCTION" >&2
			source aws-env.prod
			echo $BZDB_CHECK_HOST
			;;
		demo)
			echo "DEMO" >&2
			source aws-env.demo
			echo $BZDB_CHECK_HOST
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
}


show_help() {
cat << EOF
Usage: ${0##*/} [-p]

Checks for the BZ database
	-dev		DEVELOPMENT	
	-prod		PRODUCTION
	-demo		DEMO

EOF
}

while getopts "pd" opt
do
	case $opt in
		dev)
			echo "DEVELOPMENT" >&2
			source aws-env.dev
			;;
		prod)
			echo "PRODUCTION" >&2
			source aws-env.prod
			;;
		demo)
			echo "DEMO" >&2
			source aws-env.demo
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
done

shift "$((OPTIND-1))"   # Discard the options and sentinel --

echo Describing $STAGE

curl -H "Authorization: Bearer $API_ACCESS_TOKEN" https://$BZDB_CHECK_HOST/describe
