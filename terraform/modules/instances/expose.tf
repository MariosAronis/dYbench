output "Validators-Private-IPs" {
  value = ["${aws_instance.dybench-node.*.private_ip}"]
}

output "VPN-Server-IP" {
  value = [aws_instance.dybench_vpn.public_ip]
}

output "VPN-Server-Private-IP" {
  value = [aws_instance.dybench_vpn.private_ip]
}