#!/bin/bash -x

KERBEROS={{kerberos}}

DEBUG_PORT={{llap_debug_port}}
HIVE_ARGS=" -XX:+UseG1GC -XX:+ResizeTLAB -XX:+UseNUMA  -XX:-ResizePLAB -verbose:class "

# Start LLAP daemon with remote debugging enabled (waiting for connect)
if [[ ! -z "$DEBUG_PORT" ]]; then
    HIVE_ARGS="$HIVE_ARGS -Xdebug -Xrunjdwp:transport=dt_socket,address=$DEBUG_PORT,server=y,suspend=y"
fi

source /common.sh
kerberos_auth hive/llap.example.com

# hdfs dfs -mkdir /tmp/
# hdfs dfs -chmod 777 /tmp/

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

hdfs dfs -mkdir -p /user/hive/.yarn/package/LLAP/
hdfs dfs -chmod 777 /user/hive/.yarn/package/LLAP/
rm /hive/lib/guava-*
cp /hadoop/share/hadoop/hdfs/lib/guava-* /hive/lib/

hive --service llap --name dhive-llap --instances 1 --size 1024m --logger console --loglevel DEBUG \
    --args "$HIVE_ARGS"

# hdfs dfs -copyFromLocal /var/keytabs/hdfs.keytab /user/hive/

pushd ./llap-yarn-*/
tar_name=$(ls llap-*)
popd

if [ "$KERBEROS" = "no_kerberos" ]; then
    echo "Not adding kerberos line to llap"
else
    echo "Adding kerberos line to llap"
    sed -i 's/\"principal_name\".*/\"principal_name\" : \"hive\/_HOST@EXAMPLE.COM\",/g' ./llap-yarn-*/Yarnfile
    sed -i 's/\"keytab\".*/\"keytab\" : \"hdfs:\/\/\/user\/hive\/hdfs.keytab\"/g' ./llap-yarn-*/Yarnfile
fi

sed -i 's/\"LLAP_DAEMON_LOG_LEVEL\".*/\"LLAP_DAEMON_LOG_LEVEL\": \"DEBUG\",/g' ./llap-yarn-*/Yarnfile
sed -i 's/\"yarn.service.rolling-log.include-pattern\".*/\"yarn.service.rolling-log.include-pattern\" : \"\.\*\", \"yarn.service.log.include-pattern\" : \"\.\*\",/g' ./llap-yarn-*/Yarnfile
sed -i "s/\"id\".*/\"id\" : \"\/user\/hive\/.yarn\/package\/LLAP\/$tar_name\",/g" ./llap-yarn-*/Yarnfile

pushd ./llap-yarn-*/
mkdir llap_temp
tar -xvzf llap-*tar.gz -C llap_temp
pushd llap_temp/
#cp /hadoop-{{ hadoop_version }}/share/hadoop/yarn/hadoop-yarn-services-api-{{ hadoop_version }}.jar lib/
#cp /hadoop-{{ hadoop_version }}/share/hadoop/yarn/hadoop-yarn-services-core-{{ hadoop_version }}.jar lib/
cp conf/hadoop-metrics2.properties conf/hadoop-metrics2-llapdaemon.properties
tar czf ../llap-*tar.gz *
popd
popd
hdfs dfs -copyFromLocal llap-yarn-*/$tar_name  /user/hive/.yarn/package/LLAP/
./llap-yarn-*/run.sh
/sleep.sh
