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

We used to start from a prime sql, but that had a couple of drawbacks:

* The prime sql schema was often out of date or unused/untested
* When starting from scratch, you had to manually create users `Accounts.createUser` to sync the [Frontend](https://github.com/unee-t/frontend)
* The dev environment is more likely to have an existing / interesting bug state to be fixed locally

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

Make sure your local .env is correctly setup with `./env-setup.bash`

	docker-compose up -d db # Just start the database at first, should be empty
	# Restore dev snapshot
	mysql -h 127.0.0.1 -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD bugzilla < dev-backup.sql
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

Note that the **BUGZILLA_ADMIN_KEY** aka the API key which AFAIK can only be
setup on a running Bugzilla install via the Web interface. RE https://github.com/unee-t/bugzilla-customisation/issues/9

# Debug your Docker image by entering it

	docker exec -it docker_bugzilla_1 /bin/bash

The prefix `docker_` might be different on your system.

# Database explorer

http://localhost:8082/ see [environment](.env) for credentials

# Release process for production

Consider doing this at a quiet time though not on a Friday afternoon as
developers would like to relax typically then like everyone else.

Release manager needs to ensure a seamless UX for the end user by:

1. Track and read commits since last release
2. Communicate with developers about the current stability and anything pending
3. Conduct tests on https://case.dev.unee-t.com/ (often most time consuming job) and try offload this to https://uilicious.com/
4. If everything looks good, a judgement call is made and the release is **tagged* and pushed
5. Follow up: Track the [CI/CD](https://travis-ci.org/unee-t/frontend) actually deployed the changes
6. **Verify COMMIT in HTML header** `curl -s https://case.unee-t.com | grep COMMIT`
7. [View ECS events](https://media.dev.unee-t.com/2018-10-03/meteor.png) for any issues. [Tail logs](https://github.com/TylerBrock/saw) for anything untoward
8. Write release notes aka communicate with users about new features or fixes that make their lives easier
9. Solicit feedback from users

# JSON API

<https://bugzilla.readthedocs.io/en/latest/api/>

	curl http://localhost:8081/rest/bug/1?api_key=$(aws --profile uneet-dev ssm get-parameters --names BUGZILLA_ADMIN_KEY --with-decryption --query Parameters[0].Value --output text) | jq

# Build

You shouldn't need to do this since normally we should use our [Docker hosted Bugzilla image](https://hub.docker.com/r/uneet/).

	make build

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

# Local demo install notes

Launch ec2 install with the
[ecsInstanceRole](https://console.aws.amazon.com/iam/home?region=ap-southeast-1#/roles/ecsInstanceRole)
with has parameter store access permissions. Ensure the Security Group allows
**All TCP** else you won't be access the demo.

Install Docker and git:

	sudo yum install docker git

Setup docker permissions:

	sudo gpasswd -a ${USER} docker
	sudo systemctl restart docker
	logout

And ssh back in...

Install docker compose:

	sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

Now get everything running:

	make up

You can also have a look at this [video explainer - How to install Unee-T on AWS EC2](https://vimeo.com/264168929) for step by step instructions on how to do this.

Make sure your images are upto date: `docker-compose pull`

# Demo users:

When you use the docker image, we create Demo users and demo units.
Details about these demo users and demo units can be found on the [documentation about the demo environment](https://documentation.unee-t.com/2018/03/01/introduction-to-the-demo-environment/)

# Logs on Cloudwatch

How to filter for 5xx errors:

	[..., request = *HTTP*, status_code = 5**, , ,]

https://media.dev.unee-t.com/2018-08-23/bugzilla-debug.mp4

# Why slow?

https://media.dev.unee-t.com/2018-08-23/targetresponsetime.mp4

https://github.com/unee-t/whyslow
