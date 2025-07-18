resource "aws_subnet" "Private_sub" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block
  tags = {
    Name = var.Name
  }
  availability_zone = var.availability_zone
}