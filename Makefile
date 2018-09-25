.env:
	./setup-env.sh

up: .env
	docker-compose up

validate:
	docker-compose -f docker-compose.yml config

build:
	docker build -t uneet/bugzilla-customisation .

down:
	docker-compose down

pull:
	docker-compose pull

mysqlogin:
	mysql -h 127.0.0.1 -P 3306 -u root --password=uniti bugzilla

clean:
	curl https://raw.githubusercontent.com/unee-t/bz-database/master/db%20snapshots/unee-t_BZDb_clean_with_demo_users_and_unit_current.sql | gzip > sql/demo.sql.gz
	sudo chown -R $$USER skin custom/ extensions/
	sudo rm -rf mariadb
