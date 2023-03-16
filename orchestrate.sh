#!/bin/bash
if [ "$#" == "0" ]; then
	echo "Look in report.pdf for instructions"
	exit 1
fi

echo "gs123sg123" | sudo -S apt-get install sshpass

HOSTLIST=()
HOSTS=""
while IFS= read -r line; do
	HOSTLIST+=($line)
	HOSTS+="$line "	
done < hosts

echo $HOSTS

case "$1" in
	start)
	  echo "Starting cassandra cluster $HOSTS" 
	  ./startCluster $HOSTS
	  docker exec cassandra-node cqlsh -f /home/cassandra/cassandraurlshortner.cql 
	  echo "Starting Swarm"
	  docker swarm init --advertise-addr ${HOSTLIST[0]}
	  tokenString=`docker swarm join-token worker | grep docker`
	  for host in "${HOSTLIST[@]:1}"
	  do
          	sshpass -p gs123sg123 ssh $host $tokenString
          done
	  echo "Starting docker cluster"
	  echo "gs123sg123" | sudo -S chown student:student volumes/redis/dump.rdb
	  echo "gs123sg123" | sudo -S chown student:student volumes/redis/appendonlydir/*
	  docker build -t gsetia/urlshortener:test .
	  docker push gsetia/urlshortener:test
	  docker stack deploy -c docker-compose.yml a2
	;;
	stop)
	  docker stack rm a2
	  ./stopCluster $HOSTS
	  for host in "${HOSTLIST[@]}"
	  do
	  	sshpass -p gs123sg123 ssh $host "docker swarm leave --force"
	  done
	;;	
esac
	
	
