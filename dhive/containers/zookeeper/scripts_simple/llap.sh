#!/usr/bin/env bash

/apache-zookeeper-3.5.7-bin/bin/zkCli.sh <<EOF

#create /registry sasl:hive:cdrwa,world:anyone:r
#create /registry/users sasl:hive:cdrwa,world:anyone:r
#create /registry/users/hdfs sasl:hive:cdrwa,world:anyone:r
#create /registry/users/hdfs/services sasl:hive:cdrwa,world:anyone:r

#create /registry/users/hdfs/services/yarn-service sasl:hive:cdrwa,world:anyone:cdrwa
#create /registry/users/hdfs/services/yarn-service/dhive-llap sasl:hive:cdrwa,world:anyone:cdrwa

create /services sasl:hive:cdrwa,world:anyone:r
create /services/yarn sasl:hive:cdrwa,world:anyone:r
create /services/yarn/users sasl:hive:cdrwa,world:anyone:r
create /services/yarn/users/hdfs sasl:hive:cdrwa,world:anyone:r
create /services/yarn/users/hdfs/dhive-llap sasl:hive:cdrwa,world:anyone:r
create /services/yarn/users/hdfs/dhive-llap/workers sasl:hive:cdrwa,world:anyone:r

create /users sasl:hive:cdrwa,world:anyone:r
create /users/hdfs sasl:hive:cdrwa,world:anyone:r
create /users/hdfs/services sasl:hive:cdrwa,world:anyone:r
create /users/hdfs/services/yarn-service sasl:hive:cdrwa,world:anyone:r
create /users/hdfs/services/yarn-service/dhive-llap sasl:hive:cdrwa,world:anyone:r
create /users/hdfs/services/yarn-service/dhive-llap/workers sasl:hive:cdrwa,world:anyone:r

setAcl /users world:anyone:crdwa
setAcl /users/hdfs world:anyone:crdwa
setAcl /users/hdfs/services world:anyone:crdwa
setAcl /users/hdfs/services/yarn-service world:anyone:crdwa
setAcl /users/hdfs/services/yarn-service/dhive-llap world:anyone:crdwa
setAcl /users/hdfs/services/yarn-service/dhive-llap/workers world:anyone:crdwa

#setAcl /registry world:anyone:crdwa
#setAcl /registry/users world:anyone:crdwa
#setAcl /registry/users/hdfs world:anyone:crdwa
#setAcl /registry/users/hdfs/services world:anyone:crdwa
#setAcl /registry/users/hdfs/services/yarn-service world:anyone:crdwa
#setAcl /registry/users/hdfs/services/yarn-service/dhive-llap world:anyone:crdwa

EOF

# create /zkdtsm_hive_dhive-llap sasl:hive:cdrwa,world:anyone:r
# create /zkdtsm_hive_dhive-llap/ZKDTSMRoot sasl:hive:cdrwa,world:anyone:r
# create /zkdtsm_hive_dhive-llap/ZKDTSMRoot/ZKDTSMSeqNumRoot sasl:hive:cdrwa,world:anyone:r
# create /zkdtsm_hive_dhive-llap/ZKDTSMRoot/ZKDTSMKeyIdRoot sasl:hive:cdrwa,world:anyone:r
#create /zkdtsm_hive_dhive-llap/ZKDTSMRoot/ZKDTSMMasterKeyRoot sasl:hive:cdrwa,world:anyone:r
#create /zkdtsm_hive_dhive-llap/ZKDTSMRoot/ZKDTSMTokensRoot sasl:hive:cdrwa,world:anyone:r

# create /llap-sasl sasl:hive:cdrwa,world:anyone:r
# create /llap-sasl/user-hive sasl:hive:cdrwa,world:anyone:r
# create /llap-sasl/user-hive/dhive-llap sasl:hive:cdrwa,world:anyone:r
# create /llap-sasl/user-hive/dhive-llap/workers sasl:hive:cdrwa,world:anyone:r

setAcl /llap-sasl sasl:hive:cdrwa,world:anyone:r
setAcl /llap-sasl/user-hive sasl:hive:cdrwa, world:anyone:r
setAcl /llap-sasl/user-hive/dhive-llap sasl:hive:cdrwa,world:anyone:r

setAcl /registry sasl:hive:cdrwa,world:anyone:r
setAcl /registry/users sasl:hive:cdrwa,world:anyone:r
setAcl /registry/users/hdfs sasl:hive:cdrwa,world:anyone:r
setAcl /registry/users/hdfs/services sasl:hive:cdrwa,world:anyone:r
setAcl /registry/users/hdfs/services/yarn-service sasl:hive:cdrwa,world:anyone:r
setAcl /registry/users/hdfs/services/yarn-service/dhive-llap sasl:hive:cdrwa,world:anyone:r


