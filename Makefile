
DOCKER_COMPOSE_PATH=build
SCRIPTS_PATH=${DOCKER_COMPOSE_PATH}/scripts

assure-all:
	bash ${SCRIPTS_PATH}/assure_components.sh

all: generate assure-all start


generate:
	python3 dhive.py

stop:
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml down

start: stop start-monitoring
	docker volume rm hadoop-kerberos_server-keytab || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml up -d --force-recreate --build

restart-hive:
	docker rm -f hs2.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build hs2
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name hs2.example --detach --entrypoint /start-hive.sh --rm hs2

pull-logs:
	bash ${SCRIPTS_PATH}/pull_logs.sh

stop-monitoring:
	ps aux | grep SimpleHTTPServer | grep -v grep | awk '{print $$2}' | xargs kill -9 || true
	ps aux | grep forever_pull_logs.sh | grep -v grep | awk '{print $$2}' | xargs kill -9 > /dev/null 2>&1 || true

start-monitoring: stop-monitoring
	bash ${SCRIPTS_PATH}/pull_logs.sh

clean: generate stop
	bash ${SCRIPTS_PATH}/clean.sh
