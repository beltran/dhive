#!/usr/bin/env bats

@test "test_clean_all" {
  teardown () {
    make stop
  }

  make stop all
  [ "$?" -eq 0 ]
}
