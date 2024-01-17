resource "aws_s3_bucket" "dybenchd-binaries" {
  bucket = "dybenchd-binaries"

  tags = {
    Name = "dybenchd-binaries"
  }
}