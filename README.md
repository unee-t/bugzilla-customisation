Requires [docker](https://www.docker.com/) &
[docker-compose](https://docs.docker.com/compose/). Linux is definitely a plus, else run on a VPS.

# Development servers

* [AWS_PROFILE](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) `uneet-dev` AWS account # 812644853088
* [Bugzilla](https://dashboard.dev.unee-t.com)
* [Meteor](https://case.dev.unee-t.com)
* auroradb.dev.unee-t.com

# Production servers

* [AWS_PROFILE](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) `uneet-prod` AWS account # 192458993663
* [Bugzilla](https://dashboard.unee-t.com)
* [Meteor](https://case.unee-t.com)
* auroradb.unee-t.com

# Developing locally

We used to start from a [prime sql](https://github.com/unee-t/bz-database), but
now we being from existing development snapshots.

The idea now is to start from a **snapshot** of the remote development (dev)
environment. Our remote dev environment is hosted on AWS and so are all the
secrets, so you really need to get access or a copy of the credentials from one
of the existing Unee-T developers.

Finally your Frontend's Mongo state must be in sync! Use scripts in
https://github.com/unee-t/frontend/blob/master/backup/ to backup and restore
Mongo.

To initialise / reset the database for development:

	make clean
	export MYSQL_ROOT_PASSWORD=$(aws --profile uneet-dev ssm get-parameters --names MYSQL_ROOT_PASSWORD --with-decryption
--query Parameters[0].Value --output text)
	# Get a snapshot of dev
	mysqldump -R -h auroradb.dev.unee-t.com -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD bugzilla > dev-backup.sql

You want to Aurora's [mock mysql.lambda_async](https://github.com/unee-t/bz-database/issues/137#issuecomment-523731990).

Make sure your local .env is correctly setup with `./env-setup.bash`

	docker-compose up -d db # Just start the database at first, should be empty
	# Restore dev snapshot
	mysql -h db -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD bugzilla < dev-backup.sql
	make up

The dashboard administrator username / password is:

	aws --profile uneet-dev ssm get-parameters --names BZFE_ADMIN_USER --with-decryption --query Parameters[0].Value --output text
	aws --profile uneet-dev ssm get-parameters --names BZFE_ADMIN_PASS --with-decryption --query Parameters[0].Value --output text

# Bugzilla configuration notes

Bugzilla is setup by a variety of sources:

* the initial [vanilla stable bugzilla base image](https://github.com/unee-t/bugzilla)
* \*-params.json - seemingly just for URL and mailfrom address set via public URLs
* localconfig - created with the start script to set database connection parameters
* bugzilla_admin - for initial administrator user/pass (only used when starting from a blank slate)
* custom skin and templates - set via the Dockerfile

Largely co-ordinated by environment varibles in:

* .env for local
* aws-env.dev for development / testing /staging
* aws-env.prod for production

Note that the **BUGZILLA_ADMIN_KEY** needs to be in place on the table **user_api_keys**. Please study how https://github.com/unee-t/reset-demo works.

# Debug your Docker image by entering it

	docker exec -it bugzilla-customisation_bugzilla_1 /bin/bash

# Release process for production

Consider doing this at a quiet time though not on a Friday afternoon as
developers would like to relax typically then like everyone else.

Release manager needs to ensure a seamless UX for the end user by:

1. Track and read commits since last release
2. Communicate with developers about the current stability and anything pending
3. Conduct tests on https://case.demo.unee-t.com/ (often most time consuming job) and try offload this to https://uilicious.com/
4. If everything looks good, a judgement call is made and the release is **tagged* and pushed
5. Follow up: Track the [CI/CD](https://travis-ci.org/unee-t/frontend) actually deployed the changes
6. **Verify COMMIT in HTML header** `curl -s https://case.unee-t.com | grep COMMIT` or try https://version.dev.unee-t.com/
7. [View ECS events](https://media.dev.unee-t.com/2018-10-03/meteor.png) for any issues. [Tail logs](https://github.com/TylerBrock/saw) for anything untoward
8. Write release notes aka communicate with users about new features or fixes that make their lives easier
9. Solicit feedback from users

# JSON API

<https://bugzilla.readthedocs.io/en/latest/api/>

	curl http://localhost:8081/rest/bug/1?api_key=$(aws --profile uneet-dev ssm get-parameters --names BUGZILLA_ADMIN_KEY --with-decryption --query Parameters[0].Value --output text) | jq

There are more examples in Postman.

# Environment

Secrets are managed in [AWS's parameter
store](https://ap-southeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-southeast-1#Parameters:sort=Name).

## About email

`SES*` is required for email notifications. [SES dashboard](https://us-west-2.console.aws.amazon.com/ses/home?region=us-west-2#dashboard:)

How to test if email is working:

	echo -e "Subject: Test Mail\r\n\r\nThis is a test mail" | msmtp --debug -t user@example.com

Video about testing email: https://s.natalian.org/2017-10-27/uneetmail.mp4

# Debug mysql queries locally

	innotop -h 127.0.0.1 -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD

# How to check for mail when in test mode

	docker exec -it bugzilla_bugzilla_1 /bin/bash
	cat data/mailer.testfile

# AWS ECS setup

* [ECS overview](https://unee-t-media.s3-accelerate.amazonaws.com/2017/ecs-overview.mp4)
* [ECS deploy](https://unee-t-media.s3-accelerate.amazonaws.com/2017/ecs-deploy.mp4)
* `./deploy.sh` - deploy to staging/development cluster
* `./deploy.sh -p` - deploy to production

Refer to `ecs-cli compose service create -h` to create with a load balancer.

* [Development account](https://812644853088.signin.aws.amazon.com/console)
* [Production account](https://192458993663.signin.aws.amazon.com/console)

# Logs on Cloudwatch

How to filter for 5xx errors:

	[..., request = *HTTP*, status_code = 5**, , ,]

https://media.dev.unee-t.com/2018-08-23/bugzilla-debug.mp4

# Why slow?

https://media.dev.unee-t.com/2018-08-23/targetresponsetime.mp4

https://github.com/unee-t/whyslow
