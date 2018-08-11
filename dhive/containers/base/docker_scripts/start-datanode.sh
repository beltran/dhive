#! /bin/bash

source /common.sh
kerberos_auth hdfs/nn.example.com

while [ ! -f /var/keytabs/hdfs.jks ]
do
  echo "Waiting for ssl keystore to be created"
  sleep 1
done

hdfs datanode