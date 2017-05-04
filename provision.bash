#!/usr/bin/env bash
# Configures apt with dockers repository and installs docker

DOCKER_VERSION="1.12.6-0~ubuntu-trusty"

apt-get update
apt-get install -y curl ca-certificates apt-transport-https jq ruby

add-apt-repository https://apt.dockerproject.org/repo ubuntu-trusty
apt-key adv --keyserver p80.pool.sks-keyservers.net --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-get update

apt-get install -y "docker-engine=$DOCKER_VERSION"
update-grub
