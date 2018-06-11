#!/usr/bin/env bash

SCRIPTS_PATH=scripts

echo "Killing previous server and pull script"
ps aux | grep SimpleHTTPServer | awk '{print $2}' | xargs kill -9
ps aux | grep forever_pull_logs.sh | awk '{print $2}' | xargs kill -9

# Start it from the root of this proyect
# For some reason log aggregation is not working
rm -rf logs
mkdir logs

pushd logs
echo "Starting UI"
echo "YARN and apps UI at: http://localhost:8088/cluster/apps"
echo "Pulled logs from apps at: http://localhost:8000/"
nohup python -m SimpleHTTPServer 8000 &
popd

nohup $SCRIPTS_PATH/forever_pull_logs.sh &

#xdg-open http://localhost:8000/
