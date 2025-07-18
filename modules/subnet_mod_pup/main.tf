resource "aws_subnet" "Public_sub" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = var.Name
  }
  availability_zone = var.availability_zone
}