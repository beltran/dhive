#!/bin/bash -x

until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait


hdfs dfs -mkdir -p /apps/tez/

# Assuming a tez tarball generated with something like
# mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true is on
# the path
hadoop fs -copyFromLocal tez_up.tar.gz /apps/tez/tez.tar.gz

# Set small renewal interval for testing and small lifetime
#kdestroy -A
#until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com -l 60s -r 100s; do sleep 2; done
klist -f
export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*

hadoop jar $TEZ_JARS/tez-examples-{{ tez_version }}.jar \
    simplesessionexample hdfs://nn.example.com:9000/user/ifilonenko/people.txt,hdfs://nn.example.com:9000/user/ifilonenko/people.txt \
    /user/ifilonenko/,/user/ifilonenko/

echo "TEZ JOB FINISHED"
