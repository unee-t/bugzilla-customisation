#!/bin/bash

# This script creates dependencies to facilitate connection to the BZ Db
#
# We needs several variables that are maintained in different places:
#
# We needs several variables that are maintained in different places:
#	- Variables stored in the Travis CI "Settings":
#		n/a
#	- Variables stored in the aws-env.[stage] file
#		- STAGE
#		- MYSQL_HOST
#		- MYSQL_PORT
#		- MYSQL_USER
#		- MYSQL_PASSWORD
#		- MYSQL_DATABASE

domain() {
	case $1 in		
		dev)
			echo "DEVELOPMENT" >&2
			source aws-env.dev
			echo $MYSQL_HOST
			;;
		prod) 
			echo "PRODUCTION" >&2
			source aws-env.prod
			echo $MYSQL_HOST
			;;
		demo)
			echo "DEMO" >&2
			source aws-env.demo
			echo $MYSQL_HOST
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
}

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-p]

Connection to the BZ database
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

echo Connecting to ${STAGE^^} $(domain $STAGE)

echo $STAGE
echo mysql -s -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE
mysql -s -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE
