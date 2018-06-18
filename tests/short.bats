#!/usr/bin/env bats

@test "test a valid docker file is generated" {
    make generate
    docker-compose -f build/docker-compose.yml config
}


