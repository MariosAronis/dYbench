variable "cidr_prefix_testnet" {
  description = "/16 network for vpc subnets, for example 10.10 "
  type        = string
}

variable "cidr_prefix_vpn" {
  description = "/16 private network where vpn server lives, for example 10.10 "
  type        = string
}

variable "environment_name" {
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

variable "admin-public-ip" {
  type = string
}