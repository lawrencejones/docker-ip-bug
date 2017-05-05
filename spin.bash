#!/usr/bin/env bash
# Busy spin for a random period of time, then start netcat

IP_ADDRESS=$(ip addr show eth0 | perl -wnl -e '/inet ([^\/]+)/ and print $1')

echo "[$(date)] [$$] [$IP_ADDRESS] Serving on port 8080..."
while true; do
  nc -l 8080 <<< "done"
done
