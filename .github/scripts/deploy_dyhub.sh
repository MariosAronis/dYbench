#!/bin/bash

#Number of validators in out privater dymensionHub
VALIDATORS=$1
AMI="ami-079167f081a690d5a"
VALUE="dymensionHub-node"

get_vpc_id () {
VPC_ID=`aws ec2 describe-vpcs \
    --filters "Name=tag:Name, Values=dybench" \
    --output json --query 'Vpcs[*].{VpcId:VpcId}' | jq '. [] | ."VpcId"'`
echo $VPC_ID
}

get_subnet_id () {
SUBNET_ID=`aws ec2 describe-subnets \
    --filters "Name=tag:Name, Values=dybench-priv" \
    --output json --query 'Subnets[*].{SubnetId:SubnetId}' | jq '. [] | ."SubnetId"'`
echo $SUBNET_ID
}

get_sg_id () {
SG_ID=`aws ec2 describe-security-groups \
    --filters "Name=tag:Name, Values=dybench-private" \
    --output json --query 'SecurityGroups[*]'.{GroupId:GroupId} | jq '. [] | ."GroupId"'`
echo $SG_ID
}

get_iam_instance_profile () {
InstanceProfile=`aws iam get-instance-profile \
  --instance-profile-name dybenchnode-profile \
  --output text \
  --query 'InstanceProfile.Arn'`
echo $InstanceProfile
}

create_node () {
aws ec2 run-instances \
  --user-data "file://.github/scripts/cloud-init.sh" \
  --image-id $AMI \
  --count 1 \
  --instance-type t3.2xlarge \
  --key-name dybench \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":500,\"DeleteOnTermination\":true}}]" \
  --iam-instance-profile Arn=$InstanceProfile \
  --instance-initiated-shutdown-behavior terminate \
  --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value="$VALUE-$INDEX"}]" \
  --metadata-options "InstanceMetadataTags=enabled" 
}

get_node_id () {
    pass
}

delete_node () {
    pass
}

#FETCH INFRA DETAILS
VPC_ID=`get_vpc_id`
SUBNET_ID=`get_subnet_id`
SG_ID=`get_sg_id`
InstanceProfile=`get_iam_instance_profile`

#SPIN DIMENSION HUB NODES
for INDEX in $(seq $VALIDATORS); do
    create_node
done