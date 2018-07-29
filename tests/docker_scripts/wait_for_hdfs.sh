#!/usr/bin/env bash

wait_for_hdfs () {
    # Wait for port to open
    counter=0
    while [ 1 ]
    do
        curl nn.example.com:9000
        if [ $? -eq 0 ]; then
          break
        fi
        counter=$((counter+1))
        if [[ "$counter" -gt 20 ]]; then
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
