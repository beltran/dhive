#!/bin/bash

sed -i.bak 's/hive_version.*/hive_version = 3.1.1/g' ./config/*.cfg
sed -i.bak 's/hadoop_version.*/hadoop_version = 3.1.1/g' ./config/*.cfg
sed -i.bak 's/tez_version.*/tez_version = 0.9.1/g' ./config/*.cfg
sed -i.bak 's/hive_path.*//g' ./config/*.cfg
sed -i.bak 's/tez_path.*//g' ./config/*.cfg

docker network create com
