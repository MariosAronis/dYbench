output "sg-pub" {
  value = aws_security_group.dybench-sg1-public
}

output "sg-priv" {
  value = aws_security_group.dybench-sg-priv
}

output "subnet-pub" {
  value = aws_subnet.dybench-sn-public
}

output "subnet-priv" {
  value = aws_subnet.dybench-sn-priv
}

output "subnet-vpn" {
  value = aws_subnet.dybench-vpn-sn-public
}

output "secgroup-vpn" {
  value = aws_security_group.dybench-vpn-sg
}