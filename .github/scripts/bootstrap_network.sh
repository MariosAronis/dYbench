#!/bin/bash

set -ex

VALUE="dymensionHub-node-1"

get_instance_id () {
InstanceID=`aws ec2 describe-instances \
  --profile mariosee \
  --filters "Name=tag:Name,Values=$VALUE" \
            "Name=instance-state-name,Values=running" \
  --output json --query 'Reservations[*].Instances[*].{InstanceId:InstanceId}' | jq -r '.[] | .[] | ."InstanceId"'`   
echo $InstanceID 
}

BOOTSTRAP_NODE_EC2_ID=`get_instance_id`

ssm_command () {
COMMAND_ID=`aws ssm send-command \
  --profile mariosee \
  --instance-ids "$BOOTSTRAP_NODE_EC2_ID" \
  --document-name "AWS-RunShellScript" \
  --cli-input-json $COMMAND | jq -r ' ."Command" | ."CommandId"'
  `
echo $COMMAND_ID 
}

ssm_command_invocation () {
SSM_RESULT=`aws ssm get-command-invocation \
    --profile mariosee \
    --command-id $COMMAND_ID \
    --instance-id $BOOTSTRAP_NODE_EC2_ID | jq -r .`
echo $SSM_RESULT
}

COMMAND=file://.github/scripts/bootstrap.json
COMMAND_ID=`ssm_command`
COMMAND_STATUS=`ssm_command_invocation | jq -r ' ."Status"'`
# COMMAND_OUTPUT=`ssm_command_invocation | jq -r ' ."StandardOutputContent"'` 
COMMAND_OUTPUT=`ssm_command_invocation | jq -r . `
echo $COMMAND_OUTPUT