#!/bin/bash
docker rm -f  letsencrypt-apache-ubuntu-v1
docker run -d --name letsencrypt-apache-ubuntu-v1 -p 443:443 -p 80:80 gcr.io/qubeship/letsencrypt-apache-ubuntu
