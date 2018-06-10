#!/usr/bin/env bash

pull_logs(){
    echo "Pulling logs from $1"
    docker logs $1.example  &> logs/$1.txt
}


while [ 3 -lt 4 ]
do
    rm -rf logs/userlogs
    docker cp nm1.example:/hadoop/logs/userlogs/ logs/

    # So chrome opens this as a tex
    for filename in $(find logs/userlogs/ -type f); do
        mv "$filename" "$filename.txt"
    done

    pull_logs "nn"
    pull_logs "dn1"
    pull_logs "rm"
    pull_logs "nm1"
    pull_logs "run-tez"

    sleep 5
done

