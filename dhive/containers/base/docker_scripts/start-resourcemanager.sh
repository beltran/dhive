#! /bin/bash

until kinit -kt /var/keytabs/hdfs.keytab hdfs/rm.example.com; do sleep 2; done

echo "KDC is up and ready to go... starting up resource manager"

kdestroy

yarn resourcemanager
