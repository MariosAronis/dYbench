output "dybenchnode-profile" {
  value = aws_iam_instance_profile.dybenchnode-profile
}

output "dybenchnode-deploy-iam-role" {
    value = aws_iam_role.dybench-deploy-slc
}