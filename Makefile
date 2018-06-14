
SCRIPTS_PATH=scripts


assure-all:
	./${SCRIPTS_PATH}/assure_components.sh

stop:
	docker-compose down

start: stop start-monitoring
	docker volume rm hadoop-kerberos_server-keytab || true
	docker-compose up -d --force-recreate --build

pull-logs:
	./${SCRIPTS_PATH}/pull_logs.sh

stop-monitoring:
	ps aux | grep SimpleHTTPServer | grep -v grep | awk '{print $$2}' | xargs kill -9 || true
	ps aux | grep forever_pull_logs.sh | grep -v grep | awk '{print $$2}' | xargs kill -9 > /dev/null 2>&1 || true

start-monitoring: stop-monitoring
	./${SCRIPTS_PATH}/pull_logs.sh

clean: stop
	echo "Warning this is going to detroy all the images and volumes in docker"
	./${SCRIPTS_PATH}/clean.sh
