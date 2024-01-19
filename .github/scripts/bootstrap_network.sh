#!/bin/bash

set -ex

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
  --instance-ids "$BOOTSTRAP_NODE_EC2_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters $COMMAND | jq -r ' ."Command" | ."CommandId"'
  `
echo $COMMAND_ID
}

ssm_command_invocation () {
SSM_RESULT=`aws ssm get-command-invocation \
  --command-id $COMMAND_ID \
  --instance-id $BOOTSTRAP_NODE_EC2_ID | jq -r .`
echo $SSM_RESULT
}

# START NODE 1 (BOOTSTRAP/GENESIS)
COMMAND=file://.github/scripts/bootstrap.json
VALUE="dymensionHub-node-1"
INSTANCE_ID=`get_instance_id`
COMMAND_ID=`ssm_script`

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
NODE_ID=`echo $NODE_STATUS | jq ' ."NodeInfo" | ."id"'`
CHAIN_ID=`echo $NODE_STATUS | jq ' ."NodeInfo" | ."network"'`
LISTEN_ADR=`echo $NODE_STATUS | jq ' ."NodeInfo" | ."listen_addr"'`

# JOIN OTHER NODES
START=2
END=$VALIDATORS

for ((NODE_INDEX=START;NODE_INDEX<=END;NODE_INDEX++));
  do
    HOSTNAME="dymensionHub-node-$NODE_INDEX"
    COMMAND="{"commands":["#!/bin/bash","hostnamectl set-hostname $HOSTNAME"]}"
    VALUE=$HOSTNAME
    INSTANCE_ID=`get_instance_id`
    ssm_command
    COMMAND="{"commands":["#!/bin/bash","cd /home/ubuntu/dymension; su ubuntu -c 'make install'"]}"




for node in join_validators:
    build dymd
    add key
    send allocation
    create validator