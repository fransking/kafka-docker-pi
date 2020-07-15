#!/bin/bash

docker build -t fransking/kafka:2.12-2.5.0-arm32v7 .
docker image inspect fransking/kafka:2.12-2.5.0-arm32v7 --format='{{.Size}}'
