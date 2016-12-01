#!/bin/sh

# Update apt sources
apt-get update -q
apt-get install -yq apt-transport-https ca-certificates
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list
apt-get update

# Some prequisites
apt-get install -yq linux-image-extra-$(uname -r) linux-image-extra-virtual

# Install docker
apt-get install -yq docker-engine

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Allow usage for ubuntu user
sudo usermod -aG docker ubuntu

echo 'Reboot now!'
