#!/usr/bin/env bash


wait_for_ranger() {
  counter=0
    while [ 1 ]
    do
      # The or is because this command might return 1, which will make bats fail
      var=`docker logs hs2.example 2>&1 | grep RangerResourceTrie` || true
      if [ -z "$var" ]
      then
        echo "Hive still not synced with ranger"
      else
        echo "Hive synced with ranger"
        break
      fi

      counter=$((counter+1))
      if [[ "$counter" -gt 24 ]]; then
        # Just fail because the port didn't open
        echo "Waited for 12 minutes for hive to sync and it didn't happen"
        exit 1
      fi
      echo "Waiting for hive to sync with ranger"
      sleep 30
    done
}

wait_for_llap() {
  counter=0
    while [ 1 ]
    do
      # The or is because this command might return 1, which will make bats fail
      var=`docker logs llap.example 2>&1 | grep sleep.sh` || true
      if [ -z "$var" ]
      then
        echo "Llap installation hasn't yet finished"
      else
        echo "Llap installation has finished"
        break
      fi

      counter=$((counter+1))
      if [[ "$counter" -gt 16 ]]; then
        # Just fail because the port didn't open
        echo "Waited for 8 minutes for llap to get installed and it didn't happen"
        exit 1
      fi
      echo "Waiting for llap installation"
      sleep 30
    done
}

wait_for_hdfs() {
  docker cp tests/docker_scripts/wait_for_hdfs.sh "$1"nn.example:/
  docker exec -t "$1"nn.example /wait_for_hdfs.sh
}

test_hdfs () {
  wait_for_hdfs $1
  docker exec -t "$1"nn.example hdfs dfs -ls /
}

wait_for_hive() {
  docker cp tests/docker_scripts/wait_for_hive.sh "$1"hs2.example:/
  docker exec -t "$1"hs2.example /wait_for_hive.sh
  sleep 30
}

beeline_exec() {
  docker exec -t "$2"hs2.example beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/$2hs2.example.$2com@EXAMPLE.COM;hive.server2.proxy.user=hive" -e \""$1"\"
}

beeline_exec_no_auth() {
  docker exec -t hs2.example beeline -u "jdbc:hive2://127.0.0.1:10000/;hive.server2.proxy.user=hive" -e \""$1"\"
}

test_hive () {
    wait_for_hive $1
    beeline_exec 'CREATE DATABASE batsDB;' $1
    beeline_exec 'CREATE TABLE batsDB.batsTB(a int, b int);' $1
    beeline_exec 'INSERT INTO batsDB.batsTB(a, b) VALUES (2, 3);' $1
    beeline_exec 'SELECT * FROM batsDB.batsTB;' $1
}

test_hive_no_auth () {
    wait_for_hive $1
    beeline_exec_no_auth 'CREATE DATABASE batsDB;' $1
    beeline_exec_no_auth 'CREATE TABLE batsDB.batsTB(a int, b int);' $1
    beeline_exec_no_auth 'INSERT INTO batsDB.batsTB(a, b) VALUES (2, 3);' $1
    beeline_exec_no_auth 'SELECT * FROM batsDB.batsTB;' $1
}
