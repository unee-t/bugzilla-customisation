
#!/bin/bash

# This script helps you get the variables you need to deploy a local environment.
# WARNING: Local environments are LIMITED and are only good to tweak the UI.
# Find more information in the README file for this repo.

# Pre-requisite:
#	We depend on several ressources that MUST have been configured in the AWS parameter store.
#	you need access to the AWS account where the DEV environment is located

######################################################
#
# Update these variables BEFORE running this script!
#
######################################################

# Mandatory:

	# Sensitive:
		# the name of the folder where you cloned the `bugzilla-customization` code.
		BZDB_SEED_SOURCE=bzdb

	# It is OK to keep the default values included here
		API_ACCESS_TOKEN=theMainUneeTApiToken
		MYSQL_HOST=db
		MYSQL_DATABASE=bzfe
		MYSQL_BZ_USER=bzfe
		MYSQL_PASSWORD_BZ_USER=myBzfePassword
		MYSQL_PORT=3306

# Optional: 
# 	If allowed. You can also use several variables that are specific to your DEV environment.
#	Enter the name for the AWS profile that will allow you to access the AWS secrets.
	AWS_DEV_ACCOUNT_USERNAME=[aws_profile_alias]

######################################################
#
# We have everything - Stat working!
#
######################################################

# We create a function to help us get the secrets from the AWS parameter store.
ssm() {
	echo $(aws --profile $AWS_DEV_ACCOUNT_USERNAME ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
}

# Stop if the file already exists
if test -f .env
then
	echo .env already exists. Stopping.
	exit
fi

# If the file does NOT exist, create the file.

echo "************************************"
echo "We assume that you are a responsible developer and that"
echo "all the required variables have been configured as they should have!"
echo "----"
echo "The local .env file does not exist, we are creating it now"
echo "************************************"

cat << EOF > .env
API_ACCESS_TOKEN=$API_ACCESS_TOKEN
MYSQL_HOST=$MYSQL_HOST
MYSQL_PORT=$MYSQL_PORT
MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD_BZ_USER
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_BZ_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD_BZ_USER
PARAMS_URL=https://raw.githubusercontent.com/unee-t/bugzilla-customisation/master/params/local-params.json
SES_SMTP_PASSWORD=$(ssm SES_SMTP_PASSWORD)
SES_SMTP_USERNAME=$(ssm SES_SMTP_USERNAME)
SES_VERIFIED_SENDER=$(ssm EMAIL_FOR_NOTIFICATION_BZFE)
EOF

echo "The local .env file has been created"
