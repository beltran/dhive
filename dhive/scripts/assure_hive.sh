#!/usr/bin/env bash

HIVE_VERSION={{ hive_version }}
HIVE_URL=https://downloads.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
ARCHIVE_HIVE_URL=https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
HIVE_PAZ={{ hive_path }}
BASE_CONTAINER_PATH=build/containers/base

if [ "$HIVE_COMPILE" = "1" ]; then

    if [[ -z "${HIVE_PAZ}" ]]; then
        echo "HIVE_COMPILE is set but hive_path is not defined in config.vars. Aborting"
        exit 2
    else
        echo "Compiling hive and copying"
        pushd $HIVE_PAZ
        # mvn clean install package -T 8 -DskipTests=true -Dmaven.javadoc.skip=true -Pdist || { echo 'Error compiling' ; exit 1; }
        mvn clean install -Pdist -DskipTests -Dpackaging.minimizeJar=false -T 1C \
            -DskipShade -Dremoteresources.skip=true -Dmaven.javadoc.skip=true \
            -Dhadoop.version={{ hadoop_version }} || { echo 'Error compiling' ; exit 1; }
        popd
    fi

    cp $HIVE_PAZ/packaging/target/apache-hive-$HIVE_VERSION-bin.tar.gz hive.tar.gz || { echo 'Copy failed' ; exit 3; }
else
    if [[ -z "${HIVE_PAZ}" ]]; then
        echo "Downloading hive"
        wget -nc --no-check-certificate $HIVE_URL ||  wget -nc --no-check-certificate $ARCHIVE_HIVE_URL || true
        cp apache-hive-$HIVE_VERSION-bin.tar.gz hive.tar.gz
    else
        cp $HIVE_PAZ/packaging/target/apache-hive-$HIVE_VERSION-bin.tar.gz hive.tar.gz || { echo 'Copy failed' ; exit 3; }
    fi
fi

cp hive.tar.gz $BASE_CONTAINER_PATH || { echo 'Copy failed' ; exit 3; }
