.env:
	./local-env-setup.bash

up: .env
	docker-compose up

validate:
	docker-compose -f docker-compose.yml config

build:
	docker build -t uneet/bugzilla-customisation .

down:
	docker-compose down -v

pull:
	docker-compose pull

mysqlogin:
	mysql -h 127.0.0.1 -P 3306 -u root --password=uniti bugzilla

clean:
	sudo chown -R $$USER skin custom/ extensions/
	sudo rm -rf mariadb
