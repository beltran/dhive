#!/usr/bin/env bash

TEZ_PAZ=/Users/jmarhuenda/workspace/tez
TEZ_VERSION={{ tez_version }}
BUILD_PATH=build
BASE_CONTAINER_PATH=build/containers/base


if [ "$TEZ_COMPILE" = "1" ]; then

    if [[ -z "${$TEZ_COMPILE}" ]]; then
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
    echo "Doing nothing to assure Tez, relying on existing tez.tar.gz"
fi

cp tez.tar.gz $BASE_CONTAINER_PATH
