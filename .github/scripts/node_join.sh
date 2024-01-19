#!/bin/bash

set -e

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/dymd $HOME/go/bin'
chmod +x /home/ubuntu/go/bin/dymd
su ubuntu -c 'mkmdir -p $HOME/.dymension/config/; aws s3 cp s3://dybenchd-binaries/genesis.json $HOME/.dymension/config/'
su ubuntu -c '$HOME/go/bin/dymd start --json-rpc.enable > $HOME/.dymension/dymd.log 2>&1 &'