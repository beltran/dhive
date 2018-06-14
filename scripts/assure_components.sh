#!/usr/bin/env bash

VERSION=0.10.0-SNAPSHOT
TEZ_JOB_FINISH="TEZ JOB FINISHED"
SCRIPTS_PATH=scripts
HADOOP_VERSION=3.1.0
HADOOP_URL=http://www-us.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

assure_hadoop() {
    # Download only if the file doesn't exist
    wget -nc $HADOOP_URL
}

assure_tez() {
    if [ ! -f $SCRIPTS_PATH/assure_tez.sh ]; then
        echo "File $SCRIPTS_PATH/assure_tez.sh should exist"
        echo "It should generate the file ter.tar.gz in the root directory"
        echo "If a file already exists generate a noop file"
        echo "If you have local distribution you want to test"
        echo "that script is a good place to compile it and move"
        echo "it to ./ter.tar.gz. Otherwise download it and rename it"
        exit 1
    fi
    source $SCRIPTS_PATH/assure_tez.sh
}


assure_hive() {
    if [ ! -f $SCRIPTS_PATH/assure_hive.sh ]; then
        echo "File $SCRIPTS_PATH/assure_hive.sh should exist"
        echo "It should generate the file hive.tar.gz in the root directory"
        echo "If a file already exists generate a noop file"
        echo "If you have local distribution you want to test"
        echo "that script is a good place to compile it and move"
        echo "it to ./hive.tar.gz. Otherwise download it and rename it"
        exit 1
    fi
    source $SCRIPTS_PATH/assure_hive.sh
}

assure_hadoop
assure_tez
assure_hive
