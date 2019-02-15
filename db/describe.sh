#!/bin/bash

STAGE=dev

domain() {
	case $1 in
		prod) echo dbcheck.unee-t.com
		;;
		*) echo dbcheck.$1.unee-t.com
		;;
	esac
}


show_help() {
cat << EOF
Usage: ${0##*/} [-p]

By default, deploy to dev environment on AWS account 812644853088

	-p          PRODUCTION 192458993663
	-d          DEMO 915001051872

EOF
}

while getopts "pd" opt
do
	case $opt in
		p)
			echo "PRODUCTION" >&2
			STAGE=prod
			;;
		d)
			echo "DEMO" >&2
			STAGE=demo
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
done
AWS_PROFILE=uneet-$STAGE
shift "$((OPTIND-1))"   # Discard the options and sentinel --

echo Describing $STAGE

API_TOKEN=$(aws --profile $AWS_PROFILE ssm get-parameters --names API_ACCESS_TOKEN --with-decryption --query Parameters[0].Value --output text)
curl -H "Authorization: Bearer $API_TOKEN" https://$(domain $STAGE)/describe
