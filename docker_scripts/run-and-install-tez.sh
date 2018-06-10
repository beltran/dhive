#!/bin/bash -x

until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait


hdfs dfs -mkdir -p /apps/tez/

# Assuming a tez tarball generated with something like
# mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true is on
# the path
hadoop fs -copyFromLocal tez.tar.gz /apps/tez/

# Set small renewal interval for testing and small lifetime
until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com -l 30s -r 2m; do sleep 2; done
klist -f
export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*
#hadoop "$TEZ_JARS/tez-examples*.jar" orderedwordcount /user/ifilonenko/people.txt
hadoop jar $TEZ_JARS/tez-examples-0.10.0-SNAPSHOT.jar longnothing hdfs://nn.example.com:9000/user/ifilonenko/people.txt /user/ifilonenko/
hadoop fs -cat /user/ifilonenko/part-v002-o000-r-00000

echo "TEZ JOB FINISHED"
