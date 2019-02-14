#!/bin/bash

STAGE=dev

show_help() {
cat << EOF
Usage: ${0##*/} [-p]

By default, deploy to dev environment on AWS account 812644853088

	-p          PRODUCTION 192458993663
	-d          DEMO 915001051872
	-l          localhost

EOF
}

while getopts "pdl" opt
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
		l)
			echo "localhost" >&2
			STAGE=localhost
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
done
AWS_PROFILE=uneet-$STAGE
shift "$((OPTIND-1))"   # Discard the options and sentinel --

if test $AWS_PROFILE == uneet-localhost
then
	echo mongorestore -h 127.0.0.1 --drop --port 27017 $dir
else
	export MYSQL_ROOT_PASSWORD=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_ROOT_PASSWORD --with-decryption --query Parameters[0].Value --output text)
	export MYSQL_HOST=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_HOST --with-decryption --query Parameters[0].Value --output text)
	mysqldump --column-statistics=0 -R -h $MYSQL_HOST -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD bugzilla > $STAGE-backup-$(date +%s).sql
fi
