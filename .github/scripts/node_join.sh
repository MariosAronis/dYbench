#!/bin/bash

set -e

OLDLINE=$1
NEWLINE=$2

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/dymd $HOME/go/bin'
chmod +x /home/ubuntu/go/bin/dymd
su ubuntu -c 'mkmdir -p $HOME/.dymension/config/; aws s3 cp s3://dybenchd-binaries/genesis.json $HOME/.dymension/config/'
su ubuntu -c '$HOME/go/bin/dymd start --json-rpc.enable --json-rpc.address "0.0.0.0:8545" --rpc.laddr "tcp://0.0.0.0:26657" > $HOME/.dymension/dymd.log 2>&1 &'
pkill dymd
sed -i "s/$OLDLINE/$NEWLINE/g" /home/ubuntu/.dymension/config/config.toml
su ubuntu -c '$HOME/go/bin/dymd start --json-rpc.enable --json-rpc.address "0.0.0.0:8545" --rpc.laddr "tcp://0.0.0.0:26657" > $HOME/.dymension/dymd.log 2>&1 &'