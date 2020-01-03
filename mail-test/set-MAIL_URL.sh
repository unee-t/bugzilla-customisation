#!/bin/bash

STAGE=${STAGE:-dev}

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

getparam () {
    aws --profile ins-${STAGE} ssm get-parameters --names "$1" --with-decryption --query Parameters[0].Value --output text
}

USER=$(getparam SES_SMTP_USERNAME)
PASS=$(getparam SES_SMTP_PASSWORD)

VALUE=$(printf smtps://%s:%s@email-smtp.us-west-2.amazonaws.com:465 $USER $(urlencode $PASS))

aws --profile ins-$STAGE ssm put-parameter --overwrite --type SecureString --name MAIL_URL --value ${VALUE}
