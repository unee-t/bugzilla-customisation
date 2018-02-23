#!/bin/bash

cat <<END > .env
MYSQL_HOST=db
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=uniti
MYSQL_DATABASE=bugzilla
MYSQL_USER=mysql
MYSQL_PASSWORD=jai7Paib
PARAMS_URL=https://raw.githubusercontent.com/unee-t/bugzilla-customisation/master/params/local-params.json
SES_SMTP_PASSWORD=$(aws --region ap-southeast-1 ssm get-parameters --names SES_SMTP_PASSWORD --with-decryption --query Parameters[0].Value --output text)
SES_SMTP_USERNAME=$(aws --region ap-southeast-1 ssm get-parameters --names SES_SMTP_USERNAME --query Parameters[0].Value --output text)
SES_VERIFIED_SENDER=dev.case@unee-t.com
MAIL_URL=$(aws --region ap-southeast-1 ssm get-parameters --names MAIL_URL --with-decryption --query Parameters[0].Value --output text)
END
