# Overview:

## WARNINGS:

There are a few legacy things that we need to cleanup, we know...

## What this does:

This repo has been built to do several things:
- Create the docker image for the BZFE
- Deploy the latest version of the Unee-T Dashboard (BZFE)
- Facilitate the local installation of a **semi-functional Unee-T environment** locally (See the *Developing locally* section below).

## Important information and GOTCHAs:

- Our code has been built on and for Ubuntu Linux.
- Our code has NOT been tested on other platforms.
- Our code will most likely NOT work on any platform other that Ubuntu at the moment.
- We use [docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/) to containerise each Unee-T component/service
- We use AWS for **A LOT** of things. 
- The current version of the Unee-T code will NOT work as expected if not fully (i.e with all the necessary components and dependencies) deployed on AWS.
- We use Meteor/Mongo for the case interface.
- We use Bugzilla/AuroraDb-MySQL for case management.
- AWS AuroraDb is a MUST since we are using lambdas inside Db events, calls and procedures. The current version of the Unee-T code will NOT work if not on AWS AuroraDb.
- We use Travis CI for Test.
- We use Travis CI for automated deployments.

# Developing locally

To develop locally, you need to to start from a [primed sql file](https://github.com/unee-t/bz-database).

Make sure that the MongoDb and the BzDB are in sync!
We try to handle "orphan" ressources graciously but there might be some edge cases that we've missed.

## Initial setup (local):

Make sure your local .env is correctly setup.
You can run `make .env` to do that

Make sure to have a look at the file `./local-env-setup.bash` first!

Once the environment variables are OK you can run
`make up`

This will create several services locally:
- case (MEFE) accessible with your browser at: http://localhost:3000/
- dasboard (BZFE) accessible with your browser at: http://localhost:8081/

	docker-compose up -d db # Just start the database at first, should be empty
	# Restore dev snapshot
	mysql -h db -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD bugzilla < dev-backup.sql
	make up

## Initialise / reset the database for development:

- `make down`
- `make clean`
- `make up`

WIP - explain how to dump the latest version on the seed database in the local environment.

## Lambdas:

You want to Aurora's [mock mysql.lambda_async](https://github.com/unee-t/bz-database/issues/137#issuecomment-523731990).

## Debug your Docker image by entering it

	docker exec -it bugzilla-customisation_bugzilla_1 /bin/bash

## Debug mysql queries locally

	innotop -h 127.0.0.1 -P 3306 -u root --password=$MYSQL_ROOT_PASSWORD

## How to check for mail when in test mode

	docker exec -it bugzilla_bugzilla_1 /bin/bash
	cat data/mailer.testfile

# Architecture:

- When you install Unee-T, you are creating a Unee-T *Installation*.
- Each Unee-T installation is designed to have 3 different *Environments*:
  - DEV: for test and staging in "Real Life" condition (NOT local)
  - PROD: What you will use in production.
  - DEMO: A sandboxed environment that is running the same version of the code as the PROD environment.

  We are rellying HEAVILY on AWS services like SES, SQS, Lambdas, ECS, etc...
  This makes local development a bit more difficult.

## Main environment on Unee-T.com (Public)

### DEV/STAGING

* [BZFE - Unee-T Dashboard](https://dashboard.dev.unee-t.com)
* [MEFE - Unee-T Case](https://case.dev.unee-t.com)

### PRODUCTION

* [BZFE - Unee-T Dashboard](https://dashboard.unee-t.com)
* [MEFE - Unee-T Case](https://case.unee-t.com)

### DEMO

* [BZFE - Unee-T Dashboard](https://dashboard.demo.unee-t.com)
* [MEFE - Unee-T Case](https://case.demo.unee-t.com)

## AWS accounts:

Each *Environment* is deployed on a dedicated AWS account.
An *Installation* is linked to 3 different AWS accounts (DEV/STAGING, PROD and DEMO).

## Environment variables:

Secrets and environment variables are managed in [AWS's parameter
store](https://ap-southeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-southeast-1#Parameters:sort=Name).

# Release process:

Consider doing this at a quiet time though not on a Friday afternoon as developers would like to relax typically then like everyone else.

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

# Deployment

Deployments are automated with Travis CI.

- The DEV/STAGING environment is re-deployed/updated each time a commit is pushed to the `master` branch.
- The PROD and DEMO environments are re-deployed/updated each time we do a *tag release* of the `master` branch.

Each components are updated separately.
Ex: a push on the master in this repo will only update the BZFE component of the DEV/STAGING environment of the Unee-T installation.

# Backup and Restore:
https://github.com/unee-t/frontend/blob/master/backup/ to backup and restore
Mongo.

# Misc. - Things to keep in mind:

## Bugzilla configuration notes:

We rely on Bugzilla for several things.

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


## JSON API

<https://bugzilla.readthedocs.io/en/latest/api/>

	curl http://localhost:8081/rest/bug/1?api_key=$(aws --profile uneet-dev ssm get-parameters --names BUGZILLA_ADMIN_KEY --with-decryption --query Parameters[0].Value --output text) | jq

There are more examples in Postman.

## AWS ECS setup

* [ECS overview](https://unee-t-media.s3-accelerate.amazonaws.com/2017/ecs-overview.mp4)
* [ECS deploy](https://unee-t-media.s3-accelerate.amazonaws.com/2017/ecs-deploy.mp4)
* `./deploy.sh` - deploy to staging/development cluster
* `./deploy.sh -p` - deploy to production

Refer to `ecs-cli compose service create -h` to create with a load balancer.

* [Development account](https://812644853088.signin.aws.amazon.com/console)
* [Production account](https://192458993663.signin.aws.amazon.com/console)

## About email

`SES*` is required for email notifications. [SES dashboard](https://us-west-2.console.aws.amazon.com/ses/home?region=us-west-2#dashboard:)

How to test if email is working:

	echo -e "Subject: Test Mail\r\n\r\nThis is a test mail" | msmtp --debug -t user@example.com

Video about testing email: https://s.natalian.org/2017-10-27/uneetmail.mp4

## Logs on Cloudwatch

How to filter for 5xx errors:

	[..., request = *HTTP*, status_code = 5**, , ,]

https://media.dev.unee-t.com/2018-08-23/bugzilla-debug.mp4

## Why slow?

https://media.dev.unee-t.com/2018-08-23/targetresponsetime.mp4

https://github.com/unee-t/whyslow
