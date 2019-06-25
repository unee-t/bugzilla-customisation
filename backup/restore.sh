#!/bin/bash
test -f "$1" || exit

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

#export PASSWORD=$(aws --profile $AWS_PROFILE ssm get-parameters --names unee_t_root-Password --with-decryption --query Parameters[0].Value --output text)
export PASSWORD=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_ROOT_PASSWORD --with-decryption --query Parameters[0].Value --output text)
export MYSQL_HOST=$(aws --profile $AWS_PROFILE ssm get-parameters --names MYSQL_HOST --with-decryption --query Parameters[0].Value --output text)
echo Restoring $1 to $MYSQL_HOST
mysql -h $MYSQL_HOST -P 3306 -u root --password=$PASSWORD bugzilla < $1
#mysql -h $MYSQL_HOST -P 3306 -u unee_t_root --password=$PASSWORD bugzilla < $1
