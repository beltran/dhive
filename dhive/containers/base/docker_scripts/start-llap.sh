#!/usr/bin/env bash

until kinit -kt /var/keytabs/hdfs.keytab hive/llap.example.com; do sleep 2; done

mkdir -p /hive/llap
pushd /hive/llap

# Wait for tez to be copied as llap needs it
until hdfs dfs -ls /apps/tez/tez.tar.gz
do
    echo "Waiting for /apps/tez/tez.tar.gz"
    sleep 2
done

# Wait for the metastore to open the port
while ! echo exit | curl hm.example.com:9083 --connect-timeout 2; do echo "Waiting for the hive metastore to come up"; sleep 2; done

hive --service llap --name dhive-llap --instances 2 --size 256m --logger console --loglevel INFO \
    --args " -XX:+UseG1GC -XX:+ResizeTLAB -XX:+UseNUMA  -XX:-ResizePLAB"

sed -i 's/\"principal_name\".*/\"principal_name\" : \"hive\/_HOST@EXAMPLE.COM\",/g' ./llap-yarn-*/Yarnfile
sed -i 's/\"keytab\".*/\"keytab\" : \"\/var\/keytabs\/hdfs.keytab\"/g' ./llap-yarn-*/Yarnfile
sed -i 's/\"LLAP_DAEMON_LOG_LEVEL\".*/\"LLAP_DAEMON_LOG_LEVEL\": \"DEBUG\",/g' ./llap-yarn-*/Yarnfile


./llap-yarn-*/run.sh
/sleep.sh
