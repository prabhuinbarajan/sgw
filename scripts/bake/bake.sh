#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../..
app_name=`cat qube.json | jq .name | sed 's/\"//g'`
docker build -t gcr.io/qubeship/${app_name} -f scripts/bake/Dockerfile .
