#!/bin/bash

usage="$(basename "$0") [-h] [-s] [-a] -- run short or long tests
where:
    -s: short tests
    -t: travis tests
    -a: all tests
"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -s)
    echo "Running short tests"
    bats --tap tests/short.bats
    exit 0
    ;;
    -a)
    echo "Running all tests"
    bats --tap tests/short.bats
    bats --tap tests/long.bats
    bats --tap tests/travis.bats
    exit 0
    ;;
    -t)
    echo "Running travis tests"
    bats --tap tests/travis.bats
    exit 0
    ;;
    -h)
    echo $usage
    exit 0
    shift
    ;;
    *)    # unknown option
    echo $usage
    exit 1
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
