#!/usr/bin/env bash

RANGER_VERSION={{ ranger_version }}

pull_logs(){
    echo "Pulling logs from $1"
    docker logs $1.example  &> logs/$1.txt
}

while [ 3 -lt 4 ]
do
    rm -rf logs/userlogs
    docker cp nm1.example:/hadoop/logs/userlogs/ logs/
    docker cp rm.example:/hadoop/logs/ logs/

    # So chrome opens this as a tex
    for filename in $(find logs/userlogs/ -type f); do
        mv "$filename" "$filename.txt"
    done

    pull_logs "nn"
    pull_logs "dn1"
    pull_logs "rm"
    pull_logs "nm1"
    pull_logs "hs2"
    pull_logs "tez"
    pull_logs "hm"
    pull_logs "llap"

    [ ! -z "$RANGER_VERSION" ] && docker cp ranger.example:/ranger-$RANGER_VERSION-admin/ews/logs/ranger-admin-ranger-root.log logs/

    sleep 5
done

