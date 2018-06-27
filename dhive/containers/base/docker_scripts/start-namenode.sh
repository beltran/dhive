#! /bin/bash

until kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com; do sleep 2; done

echo "KDC is up and ready to go... starting up name node"

#kdestroy

hdfs namenode -format
hdfs namenode