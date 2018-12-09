#!/usr/bin/env bash

wait_for_hive () {
    # Wait for port to open
    counter=0
    while [ 1 ]
    do
        ip_address=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
        curl hs2.example.com:10000
        if [ $? -eq 0 ]; then
          break
        fi
        counter=$((counter+1))
        if [[ "$counter" -gt 12 ]]; then
          # Just fail because the port didn't open
          exit 1
        fi
        echo "Waiting for hive port to open"
        sleep 10
    done
}

wait_for_hive
echo "Finished OK"
