#! /bin/bash

until kinit -kt /var/keytabs/hdfs.keytab hdfs/rm.example.com; do sleep 2; done

echo "KDC is up and ready to go... starting up resource manager"

echo "Starting history server"
#/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
mkdir /hadoop/logs
yarn historyserver &> /hadoop/logs/historyserver.log &
export HADOOP_resourcemanager_opts=-Dhadoop.root.logger=DEBUG

# This files comes by default in the installation and overrides some
# parmeters from yarn-site.xml, not knowing exactly what parameters are set
rm $HADOOP_CONF_DIR/capacity-scheduler.xml
yarn resourcemanager
