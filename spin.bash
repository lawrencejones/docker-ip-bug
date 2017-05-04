#!/usr/bin/env bash
# Busy spin for a random period of time, then start netcat

IP_ADDRESS=$(ip addr show eth0 | perl -wnl -e '/inet ([^\/]+)/ and print $1')

echo "[$(date)] [$$] [$IP_ADDRESS] Do something busy..."
# Do something busy for a bit
head -n 8192 /dev/urandom | bzip2 -5 >> /dev/null
echo "[$(date)] [$$] [$IP_ADDRESS] Stop spinning, now listen!"

while true; do
  nc -l 8080 <<< "done"
done
