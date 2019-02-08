#!/bin/sh
export MYSQL_ROOT_PASSWORD=$(aws --profile uneet-dev ssm get-parameters --names MYSQL_ROOT_PASSWORD --with-decryption --query Parameters[0].Value --output text)
mysqldump --column-statistics=0 -R -h auroradb.dev.unee-t.com -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD bugzilla > dev-backup-$(date +%s).sql
