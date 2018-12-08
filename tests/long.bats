#!/usr/bin/env bats

setup() {
  load common
  echo "This script will erase all the existing volumes"
  sleep 5
}

# @test "test_default_vars_file_with_namespace" {
#   teardown () {
#     make namespace=name dclean
#   }
#   make namespace=name dclean all

#   test_hdfs name
#   test_hive name
# }

@test "test_default_vars_file" {
  teardown () {
    docker logs hs2.example
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
