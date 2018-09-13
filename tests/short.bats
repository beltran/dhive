#!/usr/bin/env bats

@test "test a valid docker file is generated, default cfg" {
    make generate
    docker-compose -f build/docker-compose.yml config
}

@test "test a valid docker file is generated, all files" {
    for filename in config/*.cfg; do
        DHIVE_CONFIG_FILE=$filename make generate
        docker-compose -f build/docker-compose.yml config
    done
}

@test "test a valid docker file is generated, all files with namespace" {
    for filename in config/*.cfg; do
        DHIVE_CONFIG_FILE=$filename make namespace=name_ generate
        docker-compose -f build/docker-compose.yml config
    done
}


