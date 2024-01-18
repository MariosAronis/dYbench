#######################################
# Deploy OpenVPNAS from AWS MarketPlace
#######################################

resource "aws_instance" "dybench_vpn" {
  ami                    = "ami-0be082f179862d3f7"
  instance_type          = var.vpn_instance_type
  subnet_id              = var.subnet-vpn.id
  vpc_security_group_ids = [var.secgroup-vpn]
  key_name               = var.private_key
  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }

  tags = {
    Name = "dybench-vpn"
  }

  volume_tags = {
    "Name" = "dybench-vpn-root-ebs"
  }
}


#################################################
# Compute & EBS Resources for validator cluster
#################################################

resource "aws_instance" "dybench-node" {
  count         = var.ec2-count
  ami           = var.ami
  instance_type = var.instance_type
  #   disable_api_termination = false
  subnet_id              = var.subnet-priv
  vpc_security_group_ids = [var.secgroup-priv]
  ebs_optimized          = "true"
  key_name               = var.private_key
  iam_instance_profile    = var.dybenchnode-profile.name
  user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y net-tools
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gcc make jq unzip -y
wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
USER=`getent passwd 1000 | cut -d: -f1`
tar -C /home/$USER -xzf go1.21.4.linux-amd64.tar.gz
hostnamectl set-hostname "dybench-node-${count.index}"
usermod -aG docker $USER
echo "export PATH=$PATH:/home/$USER/go/bin" >> /home/$USER/.bashrc
mkfs -t xfs /dev/nvme1n1 
mkdir /data
sudo mount /dev/nvme1n1 /data
chown -R 1000:1000 /data
chown -R 1000:1000 /home/$USER/go
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
git clone https://github.com/dymensionxyz/dymension.git
cd dymension
make install
EOF

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }

  tags = {
    Name = "dybench-node"
  }

  volume_tags = {
    "Name" = "dybench-node-root-ebs"
  }

  lifecycle {
    ignore_changes = [ami, root_block_device]
  }

}

# Create SSD volume for dybench-node
resource "aws_ebs_volume" "dybench-node-chaindata" {
  count             = var.ec2-count
  availability_zone = aws_instance.dybench-node["${count.index}"].availability_zone
  size              = var.storage
  type              = "gp2"

  tags = {
    Name = "dybench-validator-chaindata-${count.index}"
  }
}

resource "aws_volume_attachment" "dybench-node-chaindata-attach" {
  count       = var.ec2-count
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.dybench-node-chaindata["${count.index}"].id
  instance_id = aws_instance.dybench-node["${count.index}"].id
}

# resource "aws_iam_policy_attachment" "iam-role-attach" {
#   name       = "iam-role-attachment"
#   roles      = [aws_iam_role.dybench-validator-role.name]
#   policy_arn = aws_iam_policy.demo-s3-policy.arn
# }
