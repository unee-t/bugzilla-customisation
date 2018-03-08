#!/bin/bash

STAGE=${STAGE:-demo}

urlencode() {
	local LANG=C i c e=''
	for ((i=0;i<${#1};i++)); do
		c=${1:$i:1}
		[[ "$c" =~ [a-zA-Z0-9\.\~\_\-] ]] || printf -v c '%%%02X' "'$c"
		e+="$c"
	done
	echo "$e"
}

USER=$(aws --profile uneet-$STAGE ssm get-parameters --names SES_SMTP_USERNAME --query Parameters[0].Value --output text)
PASS=$(aws --profile uneet-$STAGE ssm get-parameters --names SES_SMTP_PASSWORD --with-decryption --query Parameters[0].Value --output text)

VALUE=$(printf smtps://%s:%s@email-smtp.us-west-2.amazonaws.com:465 $USER $(urlencode $PASS))

aws --profile uneet-$STAGE ssm put-parameter --overwrite --type SecureString --name MAIL_URL --value ${VALUE}
