#! /bin/bash

until kinit -kt /var/keytabs/hdfs.keytab hdfs/nm1.example.com; do sleep 2; done

echo "KDC is up and ready to go... starting up node manager"

kdestroy

yarn nodemanager
