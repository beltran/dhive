#!/usr/bin/env bash

docker rmi $(docker images | grep '^<none>' | awk '{print $3}')
docker volume ls | awk '{print $2}' | xargs docker volume rm
