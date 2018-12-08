#!/usr/bin/env bats

setup() {
  load common
  echo "This script will erase all the existing volumes"
  sleep 5
}

@test "test_mysql_vars_file" {
  teardown () {
    docker logs hs2.example
    DHIVE_CONFIG_FILE=config/mysql.cfg make dclean
  }

  DHIVE_CONFIG_FILE=config/mysql.cfg make dclean all

  test_hdfs
  test_hive
}
