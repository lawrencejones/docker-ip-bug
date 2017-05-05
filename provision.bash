#!/usr/bin/env bash
# Configures apt with dockers repository and installs docker

DOCKER_VERSION="1.12.6-0~ubuntu-trusty"

apt-get update
apt-get install -y curl ca-certificates apt-transport-https jq ruby

add-apt-repository 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'
apt-key adv --keyserver p80.pool.sks-keyservers.net --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-get update

apt-get install -y "docker-engine=$DOCKER_VERSION"
update-grub

echo "DOCKER_OPTS='--bip=172.17.0.1/16 --dns=172.17.0.1 --host=unix:///var/run/docker.sock --iptables=false '" > /etc/default/docker && service docker restart

apt-get install -y linux-image-generic-lts-zesty

echo "** New kernel installed. You need to restart this VM! **"
