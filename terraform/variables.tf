variable "region" {
  description = "AWS region"
  type        = string
}

variable "private_key" {
  description = "private key that corresponds to the AWS ec2 key used to deploy the instance"
  type        = string
  sensitive   = true
}

variable "cidr_prefix_testnet" {
  description = "/16 network for vpc subnets, for example 10.10 "
  type        = string
}

variable "cidr_prefix_vpn" {
  description = "/16 private network where vpn server lives, for example 10.10 "
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  type        = string
}

variable "vpn_instance_type" {
  description = "Type of EC2 instance hosting the vpn service"
  type        = string
}

variable "environment_name" {
  type = string
}

variable "instances_prefix" {
  type = string
}

variable "az-1" {
  description = "availability zone 1 in the selected region"
  type        = string
}

variable "az-2" {
  description = "availability zone 2 in the selected region"
  type        = string
}

variable "ec2-count" {
  description = "number of dybench nodes to deploy"
  type        = number
}

variable "storage" {
  description = "SSD size in GB"
  type        = number
}

variable "admin-public-ip" {
  type = string
}

