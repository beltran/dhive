#!/usr/bin/env bash

# Start it from the root of this proyect
# For some reason log aggregation is not working
rm -rf userlogs
mkdir userlogs
docker cp nm1.example:/hadoop/logs/userlogs/ userlogs

# So chrome opens this as a tex
for filename in $(find userlogs/ -type f); do
    mv "$filename" "$filename.txt"
done

pushd userlogs
python -m SimpleHTTPServer 8000

