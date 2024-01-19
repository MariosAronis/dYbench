#!/bin/bash

set -e

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/dymd $HOME/go/bin'
chmod +x /home/ubuntu/go/bin/dymd
su ubuntu -c '$HOME/go/bin/dymd start'
su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/genesis.json /home/ubuntu/.dymension/config/'