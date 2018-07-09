
DOCKER_COMPOSE_PATH=build
SCRIPTS_PATH=${DOCKER_COMPOSE_PATH}/scripts

assure-all:
	bash ${SCRIPTS_PATH}/assure_components.sh

all: generate assure-all start
	echo "External configuration file: ${DHIVE_CONFIG_FILE}"


generate:
	python3 dhive.py

stop: stop-monitoring
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml down

start: stop start-monitoring
	docker volume rm hadoop-kerberos_server-keytab || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml up -d --force-recreate --build

restart-ranger: generate assure-all
	docker rm -f ranger.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build ranger
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run -p 6080:6080 --name ranger.example --detach --entrypoint /start-ranger-admin.sh --rm ranger

restart-hive: generate assure-all
	docker rm -f hm.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build hm
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name hm.example --detach --entrypoint /start-hive-metastore.sh --rm hm

	docker rm -f hs2.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build hs2
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run -p 10000:10000 --name hs2.example --detach --entrypoint /start-hive.sh --rm hs2

restart-tez: generate assure-all
	docker rm -f install-tez.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build install-tez
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name install-tez.example --detach --entrypoint /install-tez.sh --rm install-tez

restart-llap: generate assure-all
	docker rm -f llap.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build llap
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name llap.example --detach --entrypoint /start-llap.sh --rm llap

pull-logs:
	bash ${SCRIPTS_PATH}/pull_logs.sh

stop-monitoring:
	ps aux | grep SimpleHTTPServer | grep -v grep | awk '{print $$2}' | xargs kill -9 || true
	ps aux | grep forever_pull_logs.sh | grep -v grep | awk '{print $$2}' | xargs kill -9 > /dev/null 2>&1 || true

start-monitoring: stop-monitoring
	bash ${SCRIPTS_PATH}/pull_logs.sh

clean: generate stop
	bash ${SCRIPTS_PATH}/clean.sh

# This will wipe out docker resources created by this Makefile and all the others that it finds
destroy-clean: clean
	bash ${SCRIPTS_PATH}/destroy_clean.sh

dclean: destroy-clean
