#!/usr/bin/env bash

@test "test_clean_all" {
  make clean all restart-hive clean
  [ "$?" -eq 0 ]
}
