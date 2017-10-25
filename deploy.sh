#!/bin/bash
#curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest && chmod +x /usr/local/bin/ecs-cli
/usr/local/bin/ecs-cli configure -c master -p lmb-dev
test -f aws-env && source aws-env

envsubst < AWS-docker-compose.yml > docker-compose-bugzilla.yml
envsubst < AWS-docker-compose-meteor.yml > docker-compose-meteor.yml

#ecs-cli compose -p meteor -f docker-compose-meteor.yml service create --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:192458993663:targetgroup/meteor/96a08bd201369039 --container-name meteor --container-port 80 --role ecsServiceRole
#ecs-cli compose -p bugzilla -f docker-compose-bugzilla.yml service create --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:192458993663:targetgroup/bugzilla/48050fbe08e545a3 --container-name bugzilla --container-port 80 --role ecsServiceRole

/usr/local/bin/ecs-cli compose -p meteor -f docker-compose-meteor.yml service up
/usr/local/bin/ecs-cli compose -p bugzilla -f docker-compose-bugzilla.yml service up
