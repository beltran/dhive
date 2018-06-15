#!/bin/bash -x

HIVE_VERSION=4.0.0-SNAPSHOT
HIVE_DFS_INSTALL=/apps/hive/install

if [[ -z "${HIVE_HOME}" ]]; then
    exit 1
fi

until kinit -kt /var/keytabs/hdfs.keytab hdfs/hs2.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait

hdfs dfs -mkdir -p $HIVE_DFS_INSTALL
hdfs dfs -copyFromLocal /hive/lib/hive-exec-$HIVE_VERSION.jar $HIVE_DFS_INSTALL
hdfs dfs -chmod g+w $HIVE_DFS_INSTALL
hdfs dfs -chown -R hive $HIVE_DFS_INSTALL

hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -mkdir -p /user/hive/tmp
hdfs dfs -mkdir /tmp

hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/tmp
hdfs dfs -chmod g+w /user/
hdfs dfs -chmod 777 /tmp
hdfs dfs -chown -R hive /user/hive/


until kinit -kt /var/keytabs/hdfs.keytab hive/hs2.example.com; do sleep 2; done

pushd /hive/tmp
hive --service metastore --hiveconf hive.root.logger=DEBUG,console &> metastore.log &

# Wait for the metastore to come up
sleep 10

# Add Tez jars to the classpath
export HIVE_CLASSPATH=$(find /tez_jars -name '*.jar')
hive --service hiveserver2 --hiveconf hive.root.logger=DEBUG,console

# To connect, like done previously in this script
# beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM"
