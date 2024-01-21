#!/bin/bash

set -ex

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/seeds.txt $HOME/seeds.txt'
source /home/ubuntu/seeds.txt 

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/dymd $HOME/go/bin'
chmod +x /home/ubuntu/go/bin/dymd
su ubuntu -c 'mkdir -p $HOME/.dymension/config/; aws s3 cp s3://dybenchd-binaries/genesis.json $HOME/.dymension/config/'
su ubuntu -c '$HOME/go/bin/dymd start --json-rpc.enable --json-rpc.address "0.0.0.0:8545" --rpc.laddr "tcp://0.0.0.0:26657" > $HOME/.dymension/dymd.log 2>&1 &'
sleep 10
pkill dymd
sed -i "s/$OLDLINE/$NEWLINE/g" /home/ubuntu/.dymension/config/config.toml
su ubuntu -c '$HOME/go/bin/dymd start --json-rpc.enable --json-rpc.address "0.0.0.0:8545" --rpc.laddr "tcp://0.0.0.0:26657" > $HOME/.dymension/dymd.log 2>&1 &'

su ubuntu -c 'dymd keys add "$HOSTNAME" --keyring-backend test'