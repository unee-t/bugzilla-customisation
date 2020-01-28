#!/bin/bash

# We need to remove hard coded variables from there.
# We need to update this like we updated ./deploy.sh

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

test -f "$1" || exit

if test $STAGE == "localhost"
then
	source .env
	export PASSWORD=$MYSQL_ROOT_PASSWORD
	export MYSQL_HOST=db
else
	export PASSWORD=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_ROOT_PASSWORD --with-decryption --query Parameters[0].Value --output text)
	export MYSQL_HOST=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_HOST --with-decryption --query Parameters[0].Value --output text)
fi

read -p "Restore $1 to $STAGE $MYSQL_HOST ? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mysql -h $MYSQL_HOST -P 3306 -u root --password=$PASSWORD < $1
fi
