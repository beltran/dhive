#!/usr/bin/env bats


setup() {
  echo "This script will erase all the existing volumes"
  sleep 5
}

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
  docker cp tests/docker_scripts/wait_for_hdfs.sh nn.example:/
  docker exec -it nn.example /wait_for_hdfs.sh
}

test_hdfs () {
  wait_for_hdfs
  docker exec -it nn.example hdfs dfs -ls /
}

wait_for_hive() {
  docker cp tests/docker_scripts/wait_for_hive.sh hs2.example:/
  docker exec -it hs2.example /wait_for_hive.sh
}

beeline_exec() {
  docker exec -it hs2.example beeline -u "jdbc:hive2://hs2.example.com:10000/;principal=hive/_HOST@EXAMPLE.COM;hive.server2.proxy.user=hive" -e \""$1"\"
}

beeline_exec_no_auth() {
  docker exec -it hs2.example beeline -u "jdbc:hive2://127.0.0.1:10000/;hive.server2.proxy.user=hive" -e \""$1"\"
}

test_hive () {
    wait_for_hive
    beeline_exec 'CREATE DATABASE batsDB;'
    beeline_exec 'CREATE TABLE batsDB.batsTB(a int, b int);'
    beeline_exec 'INSERT INTO batsDB.batsTB(a, b) VALUES (2, 3);'
    beeline_exec 'SELECT * FROM batsDB.batsTB;'
}

test_hive_no_auth () {
    wait_for_hive
    beeline_exec_no_auth 'CREATE DATABASE batsDB;'
    beeline_exec_no_auth 'CREATE TABLE batsDB.batsTB(a int, b int);'
    beeline_exec_no_auth 'INSERT INTO batsDB.batsTB(a, b) VALUES (2, 3);'
    beeline_exec_no_auth 'SELECT * FROM batsDB.batsTB;'
}

@test "test_default_vars_file" {
  teardown () {
    make dclean
  }

  make dclean all

  test_hdfs
  test_hive
}

@test "test_no_auth_file" {
  teardown () {
    DHIVE_CONFIG_FILE=config/simple_auth.cfg make dclean
  }

  DHIVE_CONFIG_FILE=config/simple_auth.cfg make dclean all

  test_hdfs
  test_hive_no_auth
}

@test "test_mysql_vars_file" {
  teardown () {
    DHIVE_CONFIG_FILE=config/mysql.cfg make dclean
  }

  DHIVE_CONFIG_FILE=config/mysql.cfg make dclean all

  test_hdfs
  test_hive_no_auth
}

@test "test_rangers_vars_file" {
  teardown () {
    DHIVE_CONFIG_FILE=config/ranger.cfg make dclean
  }

  DHIVE_CONFIG_FILE=config/ranger.cfg make dclean all

  test_hdfs
  wait_for_ranger
  test_hive
}

@test "test_llap_vars_file" {
  teardown () {
    DHIVE_CONFIG_FILE=config/llap.cfg make dclean
  }

  DHIVE_CONFIG_FILE=config/llap.cfg make dclean all

  test_hdfs
  wait_for_llap
  test_hive
}
