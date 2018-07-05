#!/usr/bin/env bash

HADOOP_VERSION={{ hadoop_version }}

kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com

# To run an example after kinit
# From nn.examples
cp ./$HADOOP_VERSION/libexec/share/hadoop/mapreduce/hadoop-mapreduce-examples-$HADOOP_VERSION.jar \
    nn.example:hadoop-mapreduce-examples-$HADOOP_VERSION.jar
hadoop jar hadoop*examples*.jar wordcount /user/random_user/people.txt /user/random_user/output/
