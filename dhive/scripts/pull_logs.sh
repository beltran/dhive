#!/usr/bin/env bash

SCRIPTS_PATH=build/scripts

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
echo "Pulled logs from apps at: http://localhost:8123/"
python -m SimpleHTTPServer 8123 >/dev/null 2>&1 &
popd

nohup bash $SCRIPTS_PATH/forever_pull_logs.sh > /dev/null 2>&1 &

#xdg-open http://localhost:8123/
