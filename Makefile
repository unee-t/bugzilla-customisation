# Create the local `.env` file
.env:
	./local-env-setup.bash

# Create a MINIMAL local installation of Unee-T
# This ONLY includes the following components:
#	- BZFE (bugzilla-customization repo)
#	- MEFE (frontend)
#	- APIENROLL (apienroll repo)
#	- UNIT (unit repo)
#	- INVITE (invite repo)
up: .env
	docker-compose up

validate:
	docker-compose -f docker-compose.yml config

build:
	docker build -t uneet/bugzilla-customisation:latest .

down:
	docker-compose down -v

pull:
	docker-compose pull

mysqlogin:
	mysql -h 127.0.0.1 -P ${MYSQL_PORT} -u ${MYSQL_BZ_USER} --password=${MYSQL_PASSWORD_BZ_USER} ${MYSQL_DATABASE}

clean:
	sudo chown -R $$USER skin custom/ extensions/
	sudo rm -rf mariadb
