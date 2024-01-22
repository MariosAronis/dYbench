#!/bin/bash

set -ex

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/accounts.json $HOME/accounts.json'

SCRIPT=$( cat <<'EOF'
for address in `jq -r ".validators_accounts | .[]" <<< $(cat $HOME/accounts.json)`; do
echo $address
$HOME/go/bin/dymd tx bank send local-user $address 1000000000000000000000000000udym --chain-id dymension_999-9 --from local-user --fees 20000000000000udym -y
done
EOF
)

su ubuntu -c "$SCRIPT"
