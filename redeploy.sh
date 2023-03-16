#!/bin/bash
echo "gs123sg123" | sudo -S chown student:student volumes/redis/dump.rdb
echo "gs123sg123" | sudo -S chown student:student volumes/redis/appendonlydir/*
docker build -t gsetia/urlshortener:test .
docker push gsetia/urlshortener:test
docker stack deploy -c docker-compose.yml a2
