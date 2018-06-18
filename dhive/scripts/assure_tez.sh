#!/usr/bin/env bash

TEZ_VERSION={{ tez_version }}
TEZ_URL=http://www-eu.apache.org/dist/tez/$TEZ_VERSION/apache-tez-$TEZ_VERSION-bin.tar.gz
TEZ_PAZ={{ tez_path }}
BASE_CONTAINER_PATH=build/containers/base

if [ "$TEZ_COMPILE" = "1" ]; then

    if [[ -z "${TEZ_PAZ}" ]]; then
        echo "TEZ_COMPILE is set but tez_path is not defined in config.vars. Aborting"
        exit 2
    else
        echo "Compiling Tez and copying"
        pushd $TEZ_PAZ
        mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true || { echo 'Error compiling' ; exit 1; }
        popd
    fi

    cp $TEZ_PAZ/tez-dist/target/tez-$TEZ_VERSION.tar.gz tez.tar.gz || { echo 'Copy failed' ; exit 3; }
else
    if [[ -z "${TEZ_PAZ}" ]]; then
        echo "Downloading tez"
        wget -nc $TEZ_URL -O tez.tar.gz || true
    else
        cp $TEZ_PAZ/tez-dist/target/tez-$TEZ_VERSION.tar.gz tez.tar.gz || { echo 'Copy failed' ; exit 3; }
    fi
fi

cp tez.tar.gz $BASE_CONTAINER_PATH
