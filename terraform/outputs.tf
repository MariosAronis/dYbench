output "dybench-private-ips" {
  value = module.ec2s-main.dybench-Private-IPs
}

output "VPN-Server-IP" {
  value = module.ec2s-main.VPN-Server-IP
}

output "VPN-Server-Private-IP" {
  value = module.ec2s-main.VPN-Server-Private-IP
}

output "dybench-deploy-IAM-Role" {
  value = module.iam-main.dybenchnode-deploy-iam-role.arn
}
