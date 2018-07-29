#! /bin/bash

source /common.sh
kerberos_auth hdfs/nn.example.com
create_keystore_if_no_kerberos

echo "KDC is up and ready to go... starting up name node"

#kdestroy

hdfs namenode -format
hdfs namenode
