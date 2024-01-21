#!/bin/bash

set -e

VALIDATORS=$1


get_instance_id () {
InstanceID=`aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$VALUE" \
            "Name=instance-state-name,Values=running" \
  --output json --query 'Reservations[*].Instances[*].{InstanceId:InstanceId}' | jq -r '.[] | .[] | ."InstanceId"'`
echo $InstanceID
}

ssm_script () {
COMMAND_ID=`aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --cli-input-json $COMMAND | jq -r ' ."Command" | ."CommandId"'
  `
echo $COMMAND_ID
}

ssm_command () {
COMMAND_ID=`aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters "$parameters" | jq -r ' ."Command" | ."CommandId"'
  `
echo $COMMAND_ID
}

ssm_command_invocation () {
SSM_RESULT=`aws ssm get-command-invocation \
  --command-id $COMMAND_ID \
  --instance-id $INSTANCE_ID | jq -r .`
echo $SSM_RESULT
}

get_instance_priv_ip () {
InstancePrivIP=`aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$VALUE" \
            "Name=instance-state-name,Values=running" \
  --output json --query 'Reservations[*].Instances[*].{PrivateIpAddress:PrivateIpAddress}' | jq -r '.[] | .[] | ."PrivateIpAddress"'`
  echo $InstancePrivIP
}


# START NODE 1 (BOOTSTRAP/GENESIS)
COMMAND=file://.github/scripts/bootstrap.json
VALUE="dymensionHub-node-1"
INSTANCE_ID=`get_instance_id`
COMMAND_ID=`ssm_script`

# CREATE NETWORK MAP

NODES=$(jq --null-input \
  --arg leader "$INSTANCE_ID" \
  --argjson validators [] \
  '{"leader": $leader, "validators": $validators}')

VALIDATORS_ACCOUNTS=$(jq --null-input \
  --argjson validators_accounts [] \
  '{"validators_accounts": $validators_accounts}')

sleep 180

# COMMAND_STATUS=`ssm_command_invocation | jq -r ' ."Status"'`
# COMMAND_OUTPUT=`ssm_command_invocation | jq -r ' ."StandardOutputContent"'`
# COMMAND_OUTPUT=`ssm_command_invocation | jq -r . `
#echo $COMMAND_OUTPUT

#FETCH CHAIN-ID, BOOTSTRAP NODE LISTEN ADDRESS AND NODE ID
COMMAND=file://.github/scripts/dymd_status.json
COMMAND_ID=`ssm_script`

sleep 10

NODE_STATUS=`ssm_command_invocation | jq -r ' ."StandardOutputContent"'`
NODE_ID=`echo $NODE_STATUS | jq -r ' ."NodeInfo" | ."id"'`
CHAIN_ID=`echo $NODE_STATUS | jq ' ."NodeInfo" | ."network"'`
LISTEN_ADDR=`echo $NODE_STATUS | jq -r ' ."NodeInfo" | ."listen_addr"'`
SEED_NODE_PRIVIP=`get_instance_priv_ip`
SEED_NODE_LISTEN_PORT=`echo $LISTEN_ADDR | cut -d ":" -f 3`
SEED="$NODE_ID"@"$SEED_NODE_PRIVIP":"$SEED_NODE_LISTEN_PORT"

echo $LISTEN_ADDR
echo $SEED_NODE_LISTEN_PORT

# JOIN OTHER NODES
START=2
END=$VALIDATORS

OLDLINE='seeds = ""'
NEWLINE="seeds = \"$SEED\""


# echo -e OLDLINE=$OLDLINE\nNEWLINE=$NEWLINE > seeds.txt
echo -e OLDLINE="'"$OLDLINE"'""\n"NEWLINE="'"$NEWLINE"'" > seeds.txt
aws s3 cp seeds.txt s3://dybenchd-binaries/

for ((NODE_INDEX=START;NODE_INDEX<=END;NODE_INDEX++));
  do
    HOST_NAME="dymensionHub-node-$NODE_INDEX"
    parameters="commands='hostnamectl set-hostname {{$HOST_NAME}}'"
    VALUE=$HOST_NAME
    INSTANCE_ID=`get_instance_id`

    # ADD VALIDATOR TO NODES MAP
    OBJECT=`jq . <<< {\"$HOST_NAME\":\"$INSTANCE_ID\"}`
    NODES=`jq " .validators[.validators| length] |=$OBJECT" <<< "$NODES"`
    
    ssm_command
    parameters="commands='bash /home/ubuntu/dYbench/.github/scripts/node_join.sh'"
    COMMAND_ID=`ssm_command`
    sleep 20
    COMMAND=file://.github/scripts/fetch_address.json
    COMMAND_ID=`ssm_script`
    RESULT=`ssm_command_invocation`
    sleep 3
    ADDRESS=`jq -r .StandardOutputContent <<< $RESULT`
    echo $ADDRESS

    _OBJECT=`jq . <<< {\"$HOST_NAME\":\"$ADDRESS\"}`
    echo $_OBJECT
    VALIDATORS_ACCOUNTS=`jq " .validators_accounts[.validators_accounts| length] |=$_OBJECT" <<< "$VALIDATORS_ACCOUNTS"`
  done

  echo $NODES | jq .
  echo $VALIDATORS_ACCOUNTS | jq .

  echo $VALIDATORS_ACCOUNTS | jq . >> accounts.json
  aws s3 cp accounts.json s3://dybenchd-binaries/
 