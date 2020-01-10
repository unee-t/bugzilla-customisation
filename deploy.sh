#!/bin/bash

# This script is created to deploy the BZFE
#
# We needs several variables that are maintained in different places:
#	- Variables stored in the Travis CI "Settings":
#	  These are needed so that automated deployment are working as intended
#		- AWS_DEFAULT_REGION <--- This is probably overkill since we have this in aws-env.[stage] variables
#		- PROFILE_DEV
#		- PROFILE_PROD
#		- PROFILE_DEMO
#
#	- Variables stored in the aws-env.[stage] file
#		- STAGE
#		- PROFILE
#		- AWS_REGION
#
#	- Variables need to be set when 
#		- Option 1: .travis.yml is called.
#		- Option 2: when deploy.sh is called
#
# To run this script, run this command: `./deploy.sh -[STAGE]`
# where STAGE is either
#	- `dev` for the DEV environment
#	- `prod` for the PROD environment
#	- `demo` for the DEMO environment

# Step 1: Setup the parameters and variables we need:

set -e
echo "START $0 $(date)"

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/}
Deploy the BZFE and BZ code on AWS account
	dev 	DEVELOPMENT	
	prod	PRODUCTION
	demo	DEMO
EOF
}
while getopts "pd" opt
do
	case $opt in
		d)
			echo "DEVELOPMENT" >&2
			STAGE=dev
			;;
		p)
			echo "PRODUCTION" >&2
			STAGE=prod
			;;
		s)
			echo "DEMO" >&2
			STAGE=demo
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
done

shift "$((OPTIND-1))"   # Discard the options and sentinel --

export COMMIT=$(git rev-parse --short HEAD)

# Run deploy hooks
for hook in deploy-hooks/*
do
	[[ -x $hook ]] || continue
	if "$hook"
	then
		echo OK: "$hook"
	else
		echo FAIL: "$hook"
		exit 1
	fi
done

# This is in case there is no aws cli profile
# in that case, the aws profile needs to be created from scratch.
# This happens when:
#	- We are doing a travis CI deployment.
#	  We rely on the Travis CI settings that have been called when the
#	  .travis.yml script is called.
#	- The user has not configured his machine properly.

if ! aws configure --profile $PROFILE list
then
	# We tell the user about the issue
	echo Profile $PROFILE does not exist >&2

	if ! test "$AWS_ACCESS_KEY_ID"
	then
	# We tell the user about the issue
		echo Missing $AWS_ACCESS_KEY_ID >&2
		exit 1
	fi
	echo Attempting to setup one from the environment >&2
	echo $PROFILE
	echo $AWS_ACCESS_KEY_ID
	echo $AWS_SECRET_ACCESS_KEY
	aws configure set profile.${PROFILE}.aws_access_key_id $AWS_ACCESS_KEY_ID
	aws configure set profile.${PROFILE}.aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	aws configure set profile.${PROFILE}.region $AWS_DEFAULT_REGION
	# aws configure --profile ${PROFILE} set aws_access_key_id $AWS_ACCESS_KEY_ID
	# aws configure --profile ${PROFILE} set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	# aws configure --profile ${PROFILE} set region ${AWS_REGION}
	if ! aws configure --profile $PROFILE list
	then
	# We tell the user about the issue
		echo Profile $PROFILE does not exist on your machine >&2
		exit 1
	fi

fi
aws configure --profile $PROFILE list
if ! hash ecs-cli
then
	# We tell the user about the issue
	echo Please install https://github.com/aws/amazon-ecs-cli and ensure it is in your \$PATH
	echo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest && chmod +x /usr/local/bin/ecs-cli
	exit 1
else
	# We display the current version intalled on the user's machine.
	ecs-cli -version
fi

ecs-cli configure --cluster master --region $AWS_DEFAULT_REGION
echo Try to get Params
test -f aws-env.$STAGE && source aws-env.$STAGE
echo $API_ACCESS_TOKEN

service=$(grep -A1 services AWS-docker-compose.yml | tail -n1 | tr -cd '[[:alnum:]]')
echo Deploying $service with commit $COMMIT >&2

# Ensure docker compose file's STAGE env is empty for production
test "$STAGE" == prod && export STAGE=""

envsubst < AWS-docker-compose.yml > docker-compose-${service}.yml

# # https://github.com/aws/amazon-ecs-cli/issues/21#issuecomment-452908080
# ecs-cli compose --aws-profile $PROFILE -p ${service} -f docker-compose-${service}.yml service up \
# 	--target-group-arn ${BZFE_TARGET_ARN} \
# 	--container-name bugzilla \
# 	--container-port 80 \
# 	--create-log-groups \
# 	--deployment-max-percent 100 \
# 	--deployment-min-healthy-percent 50 \
# 	--timeout 7

# ecs-cli compose --aws-profile $PROFILE -p ${service} -f docker-compose-${service}.yml service ps

echo "END $0 $(date)"
