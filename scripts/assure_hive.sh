#!/usr/bin/env bash

#HIVE_VERSION=3.0.0 Bumping into HIVE-19740
HIVE_VERSION=4.0.0-SNAPSHOT
HIVE_URL=http://mirror.olnevhost.net/pub/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

HIVE_PAZ=/Users/jmarhuenda/workspace/hive

if [ "$HIVE_COMPILE" = "1" ]; then
    echo "Compiling hive and copying"
    pushd $HIVE_PAZ
    mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true -Pdist || { echo 'Error compiling' ; exit 1; }
    popd

    cp $HIVE_PAZ/packaging/target/apache-hive-$HIVE_VERSION-bin.tar.gz hive.tar.gz || { echo 'Copy failed' ; exit 3; }
else
    echo "Downloading hive"
    wget -nc $HIVE_URL -O hive.tar.gz || true
fi
