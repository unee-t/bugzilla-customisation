#!/bin/bash

if test -f .env
then
	echo .env already exists. Stopping.
	exit
fi

cat << EOF > .env
MYSQL_HOST=db
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=localroot
MYSQL_DATABASE=bugzilla
MYSQL_USER=bugzilla
MYSQL_PASSWORD=localbz
PARAMS_URL=https://raw.githubusercontent.com/unee-t-ins/bugzilla-customisation/master/params/local-params.json
EOF
