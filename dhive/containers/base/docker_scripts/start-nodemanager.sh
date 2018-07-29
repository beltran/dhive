#! /bin/bash

source /common.sh
kerberos_auth hdfs/nm1.example.com

echo "KDC is up and ready to go... starting up node manager"

kdestroy

yarn nodemanager
