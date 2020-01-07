#!/usr/bin/env bash

#########
# TO DO
#########
# We need to 
#   - remove the hard coded IAMUSER variables from there.
#   - make this work for the DEMO and PROD environment too.
#     This version only works for the DEV environment.
#     See the scripts connect.sh and describe.sh for example of it can be done
###############################################################################

# This script facilitates test of the IAM user connection to the BZ Db
#
# We needs several variables that are stored in the aws-env.[stage] file
#		- STAGE
#		- AWS_REGION
#       - AWS_PROFILE
#       - MYSQL_HOST
#       - MYSQL_PORT

set -x
source aws-env.dev

# HARD CODED VARIABLE

    IAMUSER="mydbuser"

# For more details:
    # https://aws.amazon.com/blogs/database/use-iam-authentication-to-connect-with-sql-workbenchj-to-amazon-aurora-mysql-or-amazon-rds-for-mysql/
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MariaDB.html#MariaDB.Concepts.SSLSupport

curl -O https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

TOKEN="$(aws --profile $AWS_PROFILE rds generate-db-auth-token --hostname $MYSQL_HOST --port $MYSQL_PORT --username $IAMUSER --region=$AWS_REGION)"

mysql -h $MYSQL_HOST -P $MYSQL_PORT --ssl-ca=./rds-combined-ca-bundle.pem --enable-cleartext-plugin --user=$IAMUSER --password=$TOKEN
