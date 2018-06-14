#!/usr/bin/env bash

#HIVE_VERSION=3.0.0 Bumping into HIVE-19740
HIVE_VERSION=2.3.3
HIVE_URL=http://mirror.olnevhost.net/pub/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

wget -nc $HIVE_URL -O hive.tar.gz