resource "aws_vpc_peering_connection" "dybench-vpn" {
  peer_vpc_id = aws_vpc.dybench-vpn.id
  vpc_id      = aws_vpc.dybench.id
  auto_accept = true

  tags = {
    Name = "dybench-vpn"
  }

  depends_on = [aws_vpc.dybench, aws_vpc.dybench-vpn]
}