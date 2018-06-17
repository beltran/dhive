#!/usr/bin/env bash

HIVE_VERSION={{ hive_version }}
HIVE_URL=http://mirror.olnevhost.net/pub/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
HIVE_PAZ={{ hive_path }}
BASE_CONTAINER_PATH=build/containers/base

if [ "$HIVE_COMPILE" = "1" ]; then

    if [[ -z "${HIVE_PAZ}" ]]; then
        echo "HIVE_COMPILE is set but hive_path is not defined in config.vars. Aborting"
        exit 2
    else
        echo "Compiling hive and copying"
        pushd $HIVE_PAZ
        mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true -Pdist || { echo 'Error compiling' ; exit 1; }
        popd
    fi

    cp $HIVE_PAZ/packaging/target/apache-hive-$HIVE_VERSION-bin.tar.gz hive.tar.gz || { echo 'Copy failed' ; exit 3; }
else
    echo "Downloading hive"
    wget -nc $HIVE_URL -O hive.tar.gz || true
fi

cp hive.tar.gz $BASE_CONTAINER_PATH
