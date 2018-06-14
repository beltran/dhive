#!/usr/bin/env bash

docker rmi $(docker images | grep '^<none>' | awk '{print $3}')
docker volume ls | grep -v "VOLUME NAME" | awk '{print $2}' | xargs docker volume rm

exit 0
