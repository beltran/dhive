#!/bin/bash -x

until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com; do sleep 2; done
until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait


hdfs dfs -rm -r /apps/tez/
hdfs dfs -mkdir -p /apps/tez/

# sudo mkdir tez_temp
# sudo chmod 777 tez_temp/
# tar -xvzf tez_up.tar.gz -C tez_temp
# pushd tez_temp/
# cp /hadoop/share/hadoop/common/hadoop-common-{{ hadoop_version }}.jar .
# sudo tar czf /../tez.tar.gz *
# popd
# sudo rm -rf tez_temp

# Assuming a tez tarball generated with something like
# mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true is on
# the path
hdfs dfs -copyFromLocal tez_up.tar.gz /apps/tez/tez.tar.gz

# Set small renewal interval for testing and small lifetime
#kdestroy -A
#until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com -l 60s -r 100s; do sleep 2; done
klist -f
export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*

# hadoop jar $TEZ_JARS/tez-examples-{{ tez_version }}.jar \
#    simplesessionexample hdfs://nn.example.com:9000/user/random_user/people.txt,hdfs://nn.example.com:9000/user/random_user/people.txt \
#    /user/random_user/,/user/random_user/
