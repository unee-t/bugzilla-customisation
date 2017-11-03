validate:
	docker-compose -f docker-compose.yml config

build:
	docker build -t uneet/bugzilla-customisation .

up:
	docker-compose up

down:
	docker-compose down

pull:
	docker-compose pull

mysqlogin:
	mysql -h 127.0.0.1 -P 3306 -u root --password=uniti bugzilla

clean:
	sudo rm -rf mariadb
