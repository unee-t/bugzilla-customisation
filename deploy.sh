#!/bin/bash

STAGE=dev

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-p]

By default, deploy to dev environment on AWS account 8126-4485-3088

	-p          PRODUCTION (1924-5899-3663)

EOF
}

while getopts "p" opt
do
	case $opt in
		p)
			echo "PRODUCTION" >&2
			STAGE=prod
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
done
AWS_PROFILE=lmb-$STAGE
shift "$((OPTIND-1))"   # Discard the options and sentinel --

#curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v0.6.6 && chmod +x /usr/local/bin/ecs-cli
/usr/local/bin/ecs-cli configure -c master -p $AWS_PROFILE -r ap-southeast-1
test -f aws-env.$STAGE && source aws-env.$STAGE

envsubst < AWS-docker-compose.yml > docker-compose-bugzilla.yml
envsubst < AWS-docker-compose-meteor.yml > docker-compose-meteor.yml

# Only user in initial setup
#ecs-cli compose -p meteor -f docker-compose-meteor.yml service create --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:192458993663:targetgroup/meteor/96a08bd201369039 --container-name meteor --container-port 80 --role ecsServiceRole
#ecs-cli compose -p bugzilla -f docker-compose-bugzilla.yml service create --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:192458993663:targetgroup/bugzilla/48050fbe08e545a3 --container-name bugzilla --container-port 80 --role ecsServiceRole

/usr/local/bin/ecs-cli compose -p meteor -f docker-compose-meteor.yml service up
#/usr/local/bin/ecs-cli compose -p bugzilla -f docker-compose-bugzilla.yml service up
