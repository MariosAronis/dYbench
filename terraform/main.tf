provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "vpc-main" {
  source              = "./modules/vpc"
  environment_name    = var.environment_name
  az-1                = var.az-1
  az-2                = var.az-2
  cidr_prefix_testnet = var.cidr_prefix_testnet
  cidr_prefix_vpn     = var.cidr_prefix_vpn
  admin-public-ip     = var.admin-public-ip
}
module "iam-main" {
  source              = "./modules/iam"
}

module "ec2s-main" {
  depends_on        = [module.vpc-main]
  source            = "./modules/instances"
  ami               = data.aws_ami.ubuntu.id
  ec2-count         = var.ec2-count
  instance_type     = var.instance_type
  subnet-priv       = module.vpc-main.subnet-priv.id
  subnet-pub        = module.vpc-main.subnet-pub.id
  secgroup-priv     = module.vpc-main.sg-priv.id
  secgroup-pub      = module.vpc-main.sg-pub.id
  storage           = var.storage
  vpn_instance_type = var.vpn_instance_type
  subnet-vpn        = module.vpc-main.subnet-vpn
  secgroup-vpn      = module.vpc-main.secgroup-vpn.id
  private_key       = var.private_key
  dybenchnode-profile = module.iam-main.dybenchnode-profile
}

# module "ecr-main" {
#   source              = "./modules/ecr"
# }

module "s3-main" {
  source = "./modules/s3"
}
