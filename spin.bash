#!/usr/bin/env bash
# Busy spin for a random period of time, then start netcat

IP_ADDRESS=$(ip addr show eth0 | perl -wnl -e '/inet ([^\/]+)/ and print $1')

if [ "$1" == "--spin" ]; then
  echo "[$(date)] [$$] [$IP_ADDRESS] Do something busy..."
  # Do something busy for a bit
  head -n 8192 /dev/urandom | bzip2 -9 >> /dev/null
  echo "[$(date)] [$$] [$IP_ADDRESS] Stop spinning, now listen!"
fi

echo "[$(date)] [$$] [$IP_ADDRESS] Serving on port 8080..."
while true; do
  nc -l 8080 <<< "done"
done
