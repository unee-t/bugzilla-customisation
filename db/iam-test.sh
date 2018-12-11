#!/usr/bin/env bash

set -x

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MariaDB.html#MariaDB.Concepts.SSLSupport
curl -O https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

# https://aws.amazon.com/blogs/database/use-iam-authentication-to-connect-with-sql-workbenchj-to-amazon-aurora-mysql-or-amazon-rds-for-mysql/
REGION="ap-southeast-1"
AURORAEP=auroradb.dev.unee-t.com
#AURORAEP=twoam2-cluster.cluster-c5eg6u2xj9yy.ap-southeast-1.rds.amazonaws.com
IAMUSER="mydbuser"

TOKEN="$(aws --profile uneet-dev rds generate-db-auth-token --hostname $AURORAEP --port 3306 --username $IAMUSER --region=$REGION)"
mysql -h $AURORAEP -P 3306 --ssl-ca=./rds-combined-ca-bundle.pem --enable-cleartext-plugin --user=$IAMUSER --password=$TOKEN
