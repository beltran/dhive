#!/bin/bash -x

HIVE_VERSION={{ hive_version }}
HIVE_DFS_INSTALL=/apps/hive/install
MYSQL_VERSION={{ mysql_connector_version }}

if [[ -z "${HIVE_HOME}" ]]; then
    exit 1
fi

until kinit -kt /var/keytabs/hdfs.keytab hdfs/hm.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait

hdfs dfs -mkdir -p /user/hive_meta/tmp

hdfs dfs -chmod g+w /user/hive_meta/tmp
hdfs dfs -chown -R hive_meta /user/hive_meta/

#until kinit -kt /var/keytabs/hdfs.keytab hive_meta/hm.example.com; do sleep 2; done
# After HIVE-20001 we have to run this with hive user
until kinit -kt /var/keytabs/hdfs.keytab hive/hm.example.com; do sleep 2; done


pushd /hive/tmp
# Add mysql jars
if [ -z "$MYSQL_VERSION" ]
then
    echo "Mysql is not being installed for the metastore"
else
    curl -L -o "`pwd`/mysql-connector-java-$MYSQL_VERSION.jar" "https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_VERSION/mysql-connector-java-$MYSQL_VERSION.jar"
    export HIVE_CLASSPATH="`pwd`/mysql-connector-java-$MYSQL_VERSION.jar"
fi
hive --service metastore --hiveconf hive.root.logger=INFO,console
