#!/usr/bin/env bash


TEZ_PAZ=/Users/jmarhuenda/workspace/tez
VERSION=0.10.0-SNAPSHOT
TEZ_JOB_FINISH="TEZ JOB FINISHED"
SCRIPTS_PATH=scripts

wait_for_tez_job () {
    for i in {1..5}
    do
        output=$(docker logs run-tez.example 2>&1 | grep "$TEZ_JOB_FINISH")
        if [ -z "output" ]
        then
            echo "Waiting to more seconds for tez job"
            sleep 2
        else
            echo "Tez job finished"
            break
        fi
        if [ $i -eq 5 ]; then
            echo "Tez job didn't finish after the waiting time"
            echo "Will still copy the logs and bring up the UI"
        fi
    done
}

pushd $TEZ_PAZ
mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true || { echo 'Error compiling' ; exit 1; }
popd

cp $TEZ_PAZ/tez-dist/target/tez-$VERSION.tar.gz tez.tar.gz || { echo 'Copy failed' ; exit 3; }

# Delete userlogs from previous runs
rm -rf userlogs

echo "Tearing down old docker instances"
docker-compose down

echo "Manually deleting kerberos volume"
docker volume rm hadoop-kerberos_server-keytab

echo "Bringing up the docker instances"
docker-compose up -d --force-recreate --build

echo "Waiting for tez job to finish"
wait_for_tez_job

echo "Getting logs"
source $SCRIPTS_PATH/pull_logs.sh
