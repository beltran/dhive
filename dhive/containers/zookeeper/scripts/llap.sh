#!/usr/bin/env bash

/zookeeper-3.4.13/bin/zkCli.sh <<EOF

create /registry sasl:hive:cdrwa,world:anyone:cdrwa
create /registry/users sasl:hive:cdrwa,world:anyone:cdrwa
create /registry/users/hdfs sasl:hive:cdrwa,world:anyone:cdrwa
create /registry/users/hdfs/services sasl:hive:cdrwa,world:anyone:cdrwa
create /registry/users/hdfs/services/yarn-service sasl:hive:cdrwa,world:anyone:cdrwa
create /registry/users/hdfs/services/yarn-service/dhive-llap sasl:hive:cdrwa,world:anyone:cdrwa

create /llap-sasl sasl:hive:cdrwa,world:anyone:r
create /llap-sasl/user-hive sasl:hive:cdrwa,world:anyone:r
create /llap-sasl/user-hive/dhive-llap sasl:hive:cdrwa,world:anyone:r
create /llap-sasl/user-hive/dhive-llap/workers sasl:hive:cdrwa,world:anyone:r


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


