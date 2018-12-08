#!/usr/bin/env bash

wait_for_hdfs () {
    # Wait for port to open
    counter=0
    while [ 1 ]
    do
        ip_address=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
        curl nn.example.com:9000
        if [ $? -eq 0 ]; then
          break
        fi
        counter=$((counter+1))
        if [[ "$counter" -gt 40 ]]; then
          # Just fail because the port didn't open
          echo "Port never opened"
          exit 1
        fi
        echo "Waiting for hdfs port to open"
        sleep 5
    done
}

wait_for_hdfs
echo "HDFS port is opened"
