#! /bin/bash

until kinit -kt /var/keytabs/hdfs.keytab hdfs/rm.example.com; do sleep 2; done

echo "KDC is up and ready to go... starting up resource manager"

kdestroy

echo "Starting history server"
#/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
mkdir /hadoop/logs
yarn historyserver &> /hadoop/logs/historyserver.log &
yarn resourcemanager
