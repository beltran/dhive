#!/bin/bash -x

HIVE_VERSION={{ hive_version }}
HIVE_DFS_INSTALL=/apps/hive/install
MYSQL_VERSION={{ mysql_connector_version }}

if [[ -z "${HIVE_HOME}" ]]; then
    exit 1
fi
source /common.sh
kerberos_auth hdfs/hm.example.com

wait_for_nn

hdfs dfsadmin -safemode wait

hdfs dfs -mkdir -p /user/hive_meta/tmp

hdfs dfs -chmod g+w /user/hive_meta/tmp
hdfs dfs -chown -R hive_meta /user/hive_meta/

#until kinit -kt /var/keytabs/hdfs.keytab hive_meta/hm.example.com; do sleep 2; done
# After HIVE-20001 we have to run this with hive user
kerberos_auth hive/hm.example.com


pushd /hive/tmp
# Add mysql jars
if [ -z "$MYSQL_VERSION" ]
then
    echo "Mysql is not being installed for the metastore"
else
    curl -L -o "`pwd`/mysql-connector-java-$MYSQL_VERSION.jar" "https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_VERSION/mysql-connector-java-$MYSQL_VERSION.jar"
    export HIVE_CLASSPATH="`pwd`/mysql-connector-java-$MYSQL_VERSION.jar"
fi

rm /hive/lib/guava-*
cp /hadoop/share/hadoop/hdfs/lib/guava-* /hive/lib/
export HIVE_CLASSPATH=$HIVE_CLASSPATH:$(find /hadoop/share/hadoop/tools/lib -name '*.jar' | tr ' ' ':')
export HIVE_CLASSPATH=$HIVE_CLASSPATH:$(echo hive/lib/*.jar | tr ' ' ':')

HADOOP_CLIENT_OPTS=-Dhive.root.logger=console hive --service metastore
/sleep.sh
