#!/bin/bash

if test -f .env
then
	echo .env already exists. Stopping.
	exit
fi

ssm() {
	echo $(aws --profile uneet-dev ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
}

cat << EOF > .env
API_ACCESS_TOKEN=$(ssm API_ACCESS_TOKEN)
MYSQL_HOST=db
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=$(ssm MYSQL_ROOT_PASSWORD)
MYSQL_DATABASE=bugzilla
MYSQL_USER=bugzilla
MYSQL_PASSWORD=$(ssm MYSQL_PASSWORD)
PARAMS_URL=https://raw.githubusercontent.com/unee-t/bugzilla-customisation/master/params/local-params.json
SES_SMTP_PASSWORD=$(ssm SES_SMTP_PASSWORD)
SES_SMTP_USERNAME=$(ssm SES_SMTP_USERNAME)
SES_VERIFIED_SENDER=dev.case@unee-t.com
EOF
