#!/bin/bash -x

source /common.sh
kerberos_auth hdfs/nn.example.com

until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done
hdfs dfsadmin -safemode wait


hdfs dfs -rm -r /apps/tez/
hdfs dfs -mkdir -p /apps/tez/

sudo mkdir tez_temp
sudo chmod 777 tez_temp/
tar -xvzf tez_up.tar.gz -C tez_temp
pushd tez_temp/
cp /hadoop/share/hadoop/common/lib/woodstox-core-*.jar .
#cp /tez_jars/*jar .
#cp /tez_jars/lib/*jar .

cp /hadoop/share/hadoop/common/hadoop-common-*.jar .
rm lib/hadoop-common-*.jar

#cp /hadoop/share/hadoop/yarn/hadoop-yarn-common-*.jar .
#cp /hadoop/share/hadoop/yarn/hadoop-yarn-api-*.jar .
#cp /hadoop/share/hadoop/common/lib/log4j-*.jar .
#cp /hadoop/share/hadoop/hdfs/lib/commons-logging-*.jar .
rm -rf lib/guava-*
rm -rf guava-*
cp /hadoop/share/hadoop/hdfs/lib/guava-* lib/
cp /hadoop/share/hadoop/hdfs/lib/guava-* .
cp /hadoop/share/hadoop/common/lib/stax2-api-*.jar .
cp /hadoop/share/hadoop/hdfs/lib/commons-configuration2-*.jar .
cp /hadoop/share/hadoop/hdfs/lib/hadoop-auth-*.jar .
cp /hadoop/share/hadoop/common/lib/htrace-core4-*-incubating.jar .
cp /hadoop/share/hadoop/hdfs/hadoop-hdfs-*.jar .
cp /hadoop/share/hadoop/common/lib/jackson-*.jar .
sudo tar czf /../tez_up.tar.gz *
popd
sudo rm -rf tez_temp

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
/sleep.sh
