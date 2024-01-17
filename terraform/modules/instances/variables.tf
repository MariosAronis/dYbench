variable "ec2-count" {
  description = "number of validator nodes to deploy"
  type        = number
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "vpn_instance_type" {
  type = string
}

variable "subnet-pub" {
  type = string
}

variable "subnet-priv" {
  type = string
}

variable "secgroup-pub" {
  type = string
}

variable "secgroup-priv" {
  type = string
}

variable "storage" {
  type = number
}

variable "subnet-vpn" {
  description = "public subnet to host the vpn server"
}

variable "secgroup-vpn" {
  description = "secgroup for vpn server"
}

variable "private_key" {}
variable "dybenchnode-profile" {}