#!/bin/bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -e HOST_IP=$1 -e ZK=$2 -i -t fransking/kafka:2.12-2.5.0-arm32v7 /bin/bash
