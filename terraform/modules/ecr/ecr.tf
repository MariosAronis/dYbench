resource "aws_ecr_repository" "evmos-validator" {
  name                 = "evmos-validator"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

 tags = {
    Name = "evmos-validator-image"
  }
}