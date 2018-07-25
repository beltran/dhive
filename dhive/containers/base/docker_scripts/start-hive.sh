#!/bin/bash -x

HIVE_VERSION={{ hive_version }}
HIVE_DFS_INSTALL=/apps/hive/install
MYSQL_VERSION={{ mysql_connector_version }}
RANGER_VERSION={{ ranger_version }}

if [[ -z "${HIVE_HOME}" ]]; then
    exit 1
fi

until kinit -kt /var/keytabs/hdfs.keytab hdfs/hs2.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait

hdfs dfs -mkdir -p /ranger/audit/ /user/hive/warehouse /user/hive/tmp/scratchdir \
    /tmp /user/hive/external/ $HIVE_DFS_INSTALL /user/hive/tmp/scratchdir/whoever \
    /user/yarn/yarn /user/yarn/framework /user/yarn/yarn/services/dhive-llap/

hdfs dfs -copyFromLocal /hive/lib/hive-exec-$HIVE_VERSION.jar $HIVE_DFS_INSTALL

hdfs dfs -chmod 700 /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/tmp
hdfs dfs -chmod 777 /user/hive/tmp/scratchdir /user/hive/external/ /tmp \
    /user/hive/tmp/scratchdir/whoever $HIVE_DFS_INSTALL /ranger/audit \
    /user/yarn/yarn /user/yarn/framework /user/yarn/yarn/services/dhive-llap/ \
    /user/yarn/yarn/services

hdfs dfs -chown -R hive /user/hive/ $HIVE_DFS_INSTALL /user/yarn/

until kinit -kt /var/keytabs/hdfs.keytab hive/hs2.example.com; do sleep 2; done

# If ranger available activate it for hive
[ ! -z "$RANGER_VERSION" ] && bash -x /start-ranger-hive.sh

# Add Tez jars to the classpath
export HIVE_CLASSPATH=$HIVE_CLASSPATH:$(find /tez_jars -name '*.jar')

echo $HIVE_CLASSPATH
#export HIVE_CLASSPATH=${TEZ_JARS}/*:${TEZ_JARS}/lib/*
HADOOP_CLIENT_OPTS=-Dhive.root.logger=INFO,console hive --service hiveserver2

# To connect, like done previously in this script
# beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM"

# jdbc:hive2://hs2.example.com:10000/>CREATE TABLE pokes (foo INT, bar STRING);
# jdbc:hive2://hs2.example.com:10000/>CREATE TABLE invites (foo INT, bar STRING) PARTITIONED BY (ds STRING);
# jdbc:hive2://hs2.example.com:10000/>SELECT * FROM pokes, invites;

/sleep.sh
