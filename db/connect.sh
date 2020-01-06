#!/bin/bash

# This script is created to dependencies needed by the BZFE
#
# We needs several variables that are maintained in different places:
#
# We needs several variables that are maintained in different places:
#	- Variables stored in the Travis CI "Settings":
#	  These are needed so that automated deployment are working as intended
#		- AWS_DEFAULT_REGION <--- This is probably overkill since we have this in aws-env.[stage] variables
#		- AWS_PROFILE_DEV
#		- AWS_PROFILE_PROD
#		- AWS_PROFILE_DEMO
#
#	- Variables stored in the aws-env.[stage] file
#		- STAGE
#		- AWS_PROFILE
#		- AWS_REGION
#
#	- Variables need to be set when 
#		- Option 1: .travis.yml is called.
#		- Option 2: when deploy.sh is called

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

Deploy the BZFE and BZ code on AWS account
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

MYSQL_PASSWORD=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_ROOT_PASSWORD --with-decryption --query Parameters[0].Value --output text)
MYSQL_USER=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_USER --with-decryption --query Parameters[0].Value --output text)

echo $STAGE
echo mysql -s -h $MYSQL_HOST -P 3306 -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE
mysql -s -h $MYSQL_HOST -P 3306 -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE
