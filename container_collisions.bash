#!/usr/bin/env bash
# Detects if docker has got into a corrupted state and has assigned an IP
# address to two or more containers.

# Returns an array of containers that have matching IPs.

docker inspect $(docker ps -q) \
| jq """
map({
  container_id: .Id,
  created_at: .Created,
  ip_address: .NetworkSettings.IPAddress
}) | group_by(.ip_address) | map(select(length > 1))
"""
