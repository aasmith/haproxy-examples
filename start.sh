#!/bin/bash

MADE_UP_BUILD_NUMBER=$((RANDOM % 1000))

docker build -t haproxy-example .
docker run -d \
  --net=host --pid=host \
  --ulimit nofile=1000000 \
  -e APP_NAME="appname-example $MADE_UP_BUILD_NUMBER" \
  -e SERVER=ipv4.icanhazip.com:80 \
  --name appname-example-$MADE_UP_BUILD_NUMBER \
  haproxy-example

echo "Deployed build '$MADE_UP_BUILD_NUMBER'."
