#!/bin/bash

set -ex

VALUE=VALUE="dymensionHub-node-1"

get_instance_id () {
InstanceID=`aws ec2 describe-instances \
  --profile mariosee \
  --filters "Name=tag:Name,Values=$VALUE" \
            "Name=instance-state-name,Values=running" \
  --output json --query 'Reservations[*].Instances[*].{InstanceId:InstanceId}' | jq -r '.[] | .[] | ."InstanceId"'`   
echo $InstanceID 
}

BOOTSTRAP_NODE_EC2_ID=`get_instance_id`

aws ssm send-command \
  --profile mariosee \
  --instance-ids "$InstaceId" \
  --document-name "AWS-RunShellScript" \
  --cli-input-json file://.github/scripts/upgrade_geth.json

