#!/bin/bash

set -e

su ubuntu -c 'aws s3 cp s3://dybenchd-binaries/accounts.json $HOME/accounts.json'

SCRIPT=$( cat <<'EOF'
for address in `jq -r ".validators_accounts | .[]" <<< $(cat $HOME/accounts.json)`; do
SEQUENCE=$($HOME/go/bin/dymd query account \
`$HOME/go/bin/dymd keys show "local-user" \
--keyring-backend test -a` \
--output json | jq -r '.base_account | .sequence');
echo $SEQUENCE;
$HOME/go/bin/dymd tx bank send local-user \
$address 10000000000000000000udym \
--chain-id dymension_999-9 \
--from "local-user" \
--fees 20000000000000udym \
--sequence $SEQUENCE \
--yes;
sleep 5
done
EOF
)

su ubuntu -c "$SCRIPT"