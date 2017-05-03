#!/usr/bin/env bash
# Busy spin for a random period of time, then start netcat

COUNT=$(((RANDOM % 10) + 5))
IP_ADDRESS=$(ip addr show eth0 | perl -wnl -e '/inet ([^\/]+)/ and print $1')

echo "[$(date)] [$$] [$IP_ADDRESS] Do something busy $COUNT times..."
while [ $((--COUNT)) != 0 ]; do
  # Do something busy for about 125ms
  head -n 512 /dev/urandom | bzip2 -5 >> /dev/null
  sleep 0.01
done
echo "[$(date)] [$$] [$IP_ADDRESS] Stop spinning, now listen!"

while true; do
  nc -l 8080 <<< "done"
done
