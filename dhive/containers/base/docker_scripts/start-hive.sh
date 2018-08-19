#!/bin/bash -x

HIVE_VERSION={{ hive_version }}
HIVE_DFS_INSTALL=/apps/hive/install
MYSQL_VERSION={{ mysql_connector_version }}
RANGER_VERSION={{ ranger_version }}
source /common.sh

if [[ -z "${HIVE_HOME}" ]]; then
    exit 1
fi

kerberos_auth hdfs/hs2.example.com

wait_for_nn

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

kerberos_auth hive/hs2.example.com

# If ranger available activate it for hive
[ ! -z "$RANGER_VERSION" ] && bash -x /start-ranger-hive.sh

# Add Tez jars to the classpath
export HIVE_CLASSPATH=$HIVE_CLASSPATH:$(find /tez_jars -name '*.jar')
export HIVE_CLASSPATH=$HIVE_CLASSPATH:$(find /hadoop/share/hadoop/tools/lib -name '*.jar')

# cp /hadoop/share/hadoop/tools/lib/* /hadoop/share/hadoop/common/lib/

echo $HIVE_CLASSPATH
#export HIVE_CLASSPATH=${TEZ_JARS}/*:${TEZ_JARS}/lib/*
sudo keytool -genkey -alias hs2.example.com -keyalg rsa -keysize 1024 -dname "CN=hs2.example.com" -keypass changeme -keystore /var/keytabs/hive.jks -storepass changeme
HADOOP_CLIENT_OPTS=-Dhive.root.logger=console hive --service hiveserver2

# To connect and excute some queries:
# beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/hs2.example.com@EXAMPLE.COM;hive.server2.proxy.user=hive/hs2.example.com@EXAMPLE.COM"

# jdbc:hive2://hs2.example.com:10000/>CREATE TABLE pokes (foo INT, bar STRING);
# jdbc:hive2://hs2.example.com:10000/>INSERT INTO pokes VALUES (1, "1");
# jdbc:hive2://hs2.example.com:10000/>SELECT * FROM pokes;

/sleep.sh
