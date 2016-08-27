#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..
app_name=`cat qube.json | jq .name | sed 's/\"//g'`
instance_name=${app_name}-v1
docker rm -f  ${instance_name}
docker run -d --name ${instance_name} -p 443:443 -p 80:80 gcr.io/qubeship/${app_name}
