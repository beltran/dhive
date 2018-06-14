#!/bin/bash -x

if [[ -z "${HIVE_HOME}" ]]; then
    exit 1
fi

until kinit -kt /var/keytabs/hdfs.keytab hdfs/hs2.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait


hdfs dfs -mkdir /user/hive/warehouse
hdfs dfs -mkdir /user/hive/tmp
hdfs dfs -mkdir /tmp

hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/tmp
hdfs dfs -chmod 777 /tmp

until kinit -kt /var/keytabs/hdfs.keytab hive/hs2.example.com; do sleep 2; done

pushd /hive/tmp
hive --service metastore --hiveconf hive.root.logger=DEBUG,console &> metastore.log &

# Wait for the metastore to come up
sleep 5
hive --service hiveserver2 --hiveconf hive.root.logger=DEBUG,console

# To connect, auth with kinit
# > beeline
# beeline> !connect jdbc:hive2://hs2.example.com:10000/;principal=hive/_HOST@EXAMPLE.COM;
