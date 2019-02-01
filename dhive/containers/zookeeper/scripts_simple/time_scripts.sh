#!/usr/bin/env bash

echo "Waiting to run the scripts against zookeeper"
sleep 30

echo "Running llap script against zookeeper"
/scripts/llap.sh
