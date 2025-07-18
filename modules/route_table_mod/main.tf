
resource "aws_route_table" "route_tab" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    gateway_id = var.IGW
  }

  tags = {
    Name = var.Name
  }
}

