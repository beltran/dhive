#!/bin/bash -x

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
while :; do
    curl hm.example.com:9083 --connect-timeout 2;
    if [ $? -ne 7 ]; then
        break
    fi
    echo "Waiting for the hive metastore to come up"; sleep 2;
done

hive --service llap --name dhive-llap --instances 1 --size 1024m --logger console --loglevel DEBUG \
    --args " -XX:+UseG1GC -XX:+ResizeTLAB -XX:+UseNUMA  -XX:-ResizePLAB"

# hdfs dfs -copyFromLocal /var/keytabs/hdfs.keytab /user/hive/

pushd ./llap-yarn-*/
tar_name=$(ls llap-*)
popd

sed -i 's/\"principal_name\".*/\"principal_name\" : \"hive\/_HOST@EXAMPLE.COM\",/g' ./llap-yarn-*/Yarnfile
sed -i 's/\"keytab\".*/\"keytab\" : \"hdfs:\/\/\/user\/hive\/hdfs.keytab\"/g' ./llap-yarn-*/Yarnfile
sed -i 's/\"LLAP_DAEMON_LOG_LEVEL\".*/\"LLAP_DAEMON_LOG_LEVEL\": \"DEBUG\",/g' ./llap-yarn-*/Yarnfile
sed -i 's/\"yarn.service.rolling-log.include-pattern\".*/\"yarn.service.rolling-log.include-pattern\" : \"\.\*\", \"yarn.service.log.include-pattern\" : \"\.\*\",/g' ./llap-yarn-*/Yarnfile
sed -i "s/\"id\".*/\"id\" : \"\/user\/hive\/.yarn\/package\/LLAP\/$tar_name\",/g" ./llap-yarn-*/Yarnfile

# pushd ./llap-yarn-*/
# mkdir llap_temp
# tar -xvzf llap-*tar.gz -C llap_temp
# pushd llap_temp/
# cp /hadoop-{{ hadoop_version }}/share/hadoop/yarn/hadoop-yarn-services-api-{{ hadoop_version }}.jar lib/
# cp /hadoop-{{ hadoop_version }}/share/hadoop/yarn/hadoop-yarn-services-core-{{ hadoop_version }}.jar lib/
# cp conf/hadoop-metrics2.properties conf/hadoop-metrics2-llapdaemon.properties
# tar czf ../llap-*tar.gz *
# popd
# popd

./llap-yarn-*/run.sh
/sleep.sh
