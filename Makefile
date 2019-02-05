
DOCKER_COMPOSE_PATH=build
SCRIPTS_PATH=${DOCKER_COMPOSE_PATH}/scripts

assure-all: generate
	bash ${SCRIPTS_PATH}/assure_components.sh

all: generate assure-all start
	echo "External configuration file: ${DHIVE_CONFIG_FILE}"

generate:
	python3 dhive.py --namespace=$(namespace)

stop: stop-monitoring
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml down


start: stop start-monitoring
	docker volume rm hadoop-kerberos_server-keytab || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml up -d --force-recreate --build

restart: assure-all rebuild-base-image
	docker-compose -f build/docker-compose.yml stop -t 1 $(service)
	docker-compose -f build/docker-compose.yml create $(service)
	docker-compose -f build/docker-compose.yml start $(service)

restart-ranger: assure-all rebuild-base-image
	docker rm -f ranger.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run -p 6080:6080 --name ranger.example --detach --entrypoint /start-ranger-admin.sh --rm ranger

restart-hive: restart-hive-server restart-hive-meta

restart-hive-meta: assure-all rebuild-base-image
	docker rm -f hm.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name hm.example --detach --entrypoint /start-hive-metastore.sh --rm hm

restart-hive-server: assure-all rebuild-base-image
	docker rm -f hs2.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run -p 10004:10004 -p 10000:10000 -p 8000:8000 --name hs2.example --detach --entrypoint /start-hive.sh --rm hs2

restart-tez: assure-all rebuild-base-image
	docker rm -f tez.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name tez.example --detach --entrypoint /install-tez.sh --rm tez

restart-llap: assure-all rebuild-base-image
	docker rm -f llap.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name llap.example --detach --entrypoint /start-llap.sh --rm llap

restart-rm: assure-all rebuild-base-image
	docker rm -f rm.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name rm.example --detach --entrypoint /start-resourcemanager.sh --rm rm

	docker rm -f nm1.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run -p 8500:8500 --name nm1.example --detach --entrypoint /start-nodemanager.sh --rm nm1

restart-zk: assure-all
	docker rm -f zk1.example || true
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run --name zk1.example --detach --entrypoint /scripts/entry_point.sh --rm zk1

rebuild-base-image:
	docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build

pull-logs:
	bash ${SCRIPTS_PATH}/pull_logs.sh

# get shell in HS2 container
hs2-shell:
	docker exec -it hs2.example /bin/bash

# run beeline in HS2 container
beeline:
	docker exec -it hs2.example beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM"	

# run beeline in HS2 container
beeline_noauth:
	docker exec -it hs2.example beeline -u "jdbc:hive2://hs2.example.com:10000/;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM"


# get a CLI for the (MySQL based) metastore database
mysqlCli:
	docker exec -it mysql.example mysql -proot_pass metastore

# will run the SchemaInit script against the metastore database (needs to be in your workspace)
mysqlInit:
	docker cp ${HOME}/workspace/hive/standalone-metastore/metastore-server/src/main/sql/mysql/hive-schema-4.0.0.mysql.sql mysql.example:/tmp	
	docker exec -t mysql.example /bin/bash -c "mysql -proot_pass --force metastore < /tmp/hive-schema-4.0.0.mysql.sql" 	

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
