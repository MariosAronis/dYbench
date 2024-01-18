#!/bin/bash

set -ex

apt-get update
apt-get install -y net-tools
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gcc make jq unzip -y
wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
USER=`getent passwd 1000 | cut -d: -f1`
tar -C /home/$USER -xzf go1.21.4.linux-amd64.tar.gz
usermod -aG docker $USER
echo "export PATH=$PATH:/home/$USER/go/bin" >> /home/$USER/.bashrc
mkfs -t xfs /dev/nvme1n1 
mkdir /data
sudo mount /dev/nvme1n1 /data
chown -R 1000:1000 /data
chown -R 1000:1000 /home/$USER/go
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
git clone https://github.com/dymensionxyz/dymension.git