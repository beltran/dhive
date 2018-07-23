#!/usr/bin/env bash

usage="$(basename "$0") [-h] [-s] [-a] -- run short or long tests
where:
    -s: short tests
    -a: all tests
"

SHORT=1
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -s)
    SHORT=1
    shift
    ;;
    -a)
    SHORT=0
    shift
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

if [ $SHORT = "1" ]; then
    echo "Running short tests"
    bats --tap tests/short.bats
else
    echo "Running all tests"
    bats --tap tests/short.bats
    bats --tap tests/long.bats
fi
