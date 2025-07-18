# -----------------------------
# VPC
# -----------------------------

module "vpc" {
  source     = "./modules/vpc_mod"
  cidr_block = "10.0.0.0/16"
}

# -----------------------------
# Elastic IP
# -----------------------------

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# -----------------------------
# Key Pairs
# -----------------------------
resource "aws_key_pair" "project" {
  key_name   = "project"
  public_key = file("~/.ssh/id_rsa.pub")
}

# -----------------------------
# Amazon S3
# -----------------------------
resource "aws_s3_bucket" "mys3statebucket" {
  bucket = "my-tf-state-project-abdallah-bucket"

  tags = {
    Name        = "My bucket"
  }
}

# -----------------------------
# Amazon DynamoDB
# -----------------------------

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-state-table"
  billing_mode = "PAY_PER_REQUEST"  
  hash_key     = "LockID"  
  attribute {
    name = "LockID"
    type = "S"
  }                    
}


# -----------------------------
# Internet Gateway
# -----------------------------

resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.project_vpc-id

  tags = {
    Name = "IG"
  }
}

# -----------------------------
# NAT Gateway
# -----------------------------

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.pub_sub_2.puplic_subnet_id_1
  depends_on = [ aws_eip.nat_eip ]
  tags = {
    Name = "NAT GW"
  }
}

# -----------------------------
# Public Subnets
# -----------------------------

module "pub_sub_1" {
  source            = "./modules/subnet_mod_pup"
  cidr_block        = "10.0.0.0/24"
  vpc_id            = module.vpc.project_vpc-id
  Name              = "Puplic Subnet 1"
  availability_zone = "us-east-1a"
}


module "pub_sub_2" {
  source            = "./modules/subnet_mod_pup"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = module.vpc.project_vpc-id
  Name              = "Puplic Subnet 2"
  availability_zone = "us-east-1b"
}

# -----------------------------
# Private Subnets
# -----------------------------
module "priv_sub_1" {
  source            = "./modules/subnet_mod_priv"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = module.vpc.project_vpc-id
  Name              = "Private Subnet 1"
  availability_zone = "us-east-1a"
}
module "priv_sub_2" {
  source            = "./modules/subnet_mod_priv"
  cidr_block        = "10.0.3.0/24"
  vpc_id            = module.vpc.project_vpc-id
  Name              = "Private Subnet 2"
  availability_zone = "us-east-1b"
}
# -----------------------------
# Route Table
# -----------------------------
module "route_table" {
  source     = "./modules/route_table_mod"
  cidr_block = "0.0.0.0/0"
  vpc_id     = module.vpc.project_vpc-id
  Name       = "Route table 1"
  IGW        = aws_internet_gateway.gw.id
}

resource "aws_route_table" "route_tab2" {
  vpc_id =module.vpc.project_vpc-id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.gw.id
  }
  tags = {
    Name = "Route Table 2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = module.pub_sub_1.puplic_subnet_id_1
  route_table_id = module.route_table.route_table_id
}
resource "aws_route_table_association" "b" {
  subnet_id      = module.pub_sub_2.puplic_subnet_id_1
  route_table_id = module.route_table.route_table_id
}
resource "aws_route_table_association" "c" {
  subnet_id      = module.priv_sub_1.private_subnet_id
  route_table_id = aws_route_table.route_tab2.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = module.priv_sub_2.private_subnet_id
  route_table_id = aws_route_table.route_tab2.id
}
# -----------------------------
# Security Groups
# -----------------------------
resource "aws_security_group" "frontEndTraffic" {
  name        = "Proxy Web Server"
  description = "allows http and ssh on instances "
  vpc_id      = module.vpc.project_vpc-id
  tags = {
    Name = "Proxy Web Server SG"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_FE" {
  security_group_id = aws_security_group.frontEndTraffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_FE" {
  security_group_id = aws_security_group.frontEndTraffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_flask_FE" {
  security_group_id = aws_security_group.frontEndTraffic.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}
resource "aws_vpc_security_group_egress_rule" "allow_all_egress_FE" {
  security_group_id = aws_security_group.frontEndTraffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "backEndTraffic" {
  name        = "BackEnd Web Server"
  description = "allows http and ssh on instances "
  vpc_id      = module.vpc.project_vpc-id
  tags = {
    Name = "BackEnd Web Server SG"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_BE" {
  security_group_id = aws_security_group.backEndTraffic.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_BE" {
  security_group_id = aws_security_group.backEndTraffic.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_flask_BE" {
  security_group_id = aws_security_group.backEndTraffic.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_BE" {
  security_group_id = aws_security_group.backEndTraffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
# -----------------------------
# Amazon Machine Image
# -----------------------------
data "aws_ami" "amz-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}
# -----------------------------
# EC2 Instance
# -----------------------------
module "proxy_instance" {
  source              = "./modules/instance_proxy_mod"
  ami_id              = data.aws_ami.amz-ami.image_id
  instance_type       = "t2.micro"
  subnet_id           = module.pub_sub_1.puplic_subnet_id_1
  security_group_id   = aws_security_group.frontEndTraffic.id
  key_name            = "project"
  private_key_path    = "~/.ssh/id_rsa"
  script_source       = "proxyscript.sh"
  backend_dns         = aws_lb.BE_LB.dns_name

  keypair_dependency     = aws_key_pair.project
  backend_lb_dependency  = aws_lb.BE_LB
  instance_name          = "Proxy Server"
}

module "proxy_instance2" {
  source              = "./modules/instance_proxy_mod"
  ami_id              = data.aws_ami.amz-ami.image_id
  instance_type       = "t2.micro"
  subnet_id           = module.pub_sub_2.puplic_subnet_id_1
  security_group_id   = aws_security_group.frontEndTraffic.id
  key_name            = "project"
  private_key_path    = "~/.ssh/id_rsa"
  script_source       = "proxyscript.sh"
  backend_dns         = aws_lb.BE_LB.dns_name

  keypair_dependency     = aws_key_pair.project
  backend_lb_dependency  = aws_lb.BE_LB
  instance_name          = "Proxy Server 2"
}

module "backend_instance" {
  source              = "./modules/instance_backend_mod"
  ami_id              = data.aws_ami.amz-ami.image_id
  instance_type       = "t2.micro"
  subnet_id           = module.priv_sub_1.private_subnet_id
  security_group_id   = aws_security_group.backEndTraffic.id
  key_name            = "project"
  private_key_path    = "~/.ssh/id_rsa"
  flask_app_path      = "flask_website/cuteblog-flask"
  setup_script_path   = "backendscript.sh"
  bastion_host        = module.proxy_instance.public_ip
  depends_on = [ aws_key_pair.project, aws_nat_gateway.gw, module.proxy_instance.instance_id ]
  instance_name = "BE Webserver"
}

module "backend_instance2" {
  source              = "./modules/instance_backend_mod"
  ami_id              = data.aws_ami.amz-ami.image_id
  instance_type       = "t2.micro"
  subnet_id           = module.priv_sub_2.private_subnet_id
  security_group_id   = aws_security_group.backEndTraffic.id
  key_name            = "project"
  private_key_path    = "~/.ssh/id_rsa"
  flask_app_path      = "flask_website/cuteblog-flask"
  setup_script_path   = "backendscript.sh"
  bastion_host        = module.proxy_instance.public_ip
  depends_on = [ aws_key_pair.project, aws_nat_gateway.gw, module.proxy_instance2.instance_id ]
  instance_name = "BE Webserver 2"
}
# -----------------------------
# Internal Load Balancer
# -----------------------------
resource "aws_lb" "BE_LB" {
  name               = "BackEnd-LB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backEndTraffic.id]
  subnets            = [ module.priv_sub_1.private_subnet_id,module.priv_sub_2.private_subnet_id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
  provisioner "local-exec" {
    command = "echo Internal LB DNS ${self.dns_name} >> all_ips.txt"
  }
}

resource "aws_lb_target_group" "BE_Target_Group" {
  name     = "BackEnd-TG"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = module.vpc.project_vpc-id
}

resource "aws_lb_target_group_attachment" "BE_TG_Attach" {
  depends_on = [ module.backend_instance ]
  target_group_arn = aws_lb_target_group.BE_Target_Group.arn
  target_id        = module.backend_instance.instance_id
  port             = 5000
}

resource "aws_lb_target_group_attachment" "BE_TG_Attach2" {
  depends_on = [ module.backend_instance2 ]
  target_group_arn = aws_lb_target_group.BE_Target_Group.arn
  target_id        = module.backend_instance2.instance_id
  port             = 5000
}

resource "aws_lb_listener" "BackEnd_l" {
  load_balancer_arn = aws_lb.BE_LB.arn
  port              = "5000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.BE_Target_Group.arn
  }
}
# -----------------------------
# Internet Facing Load Balancer
# -----------------------------
resource "aws_lb" "FE_LB" {
  name               = "FrontEnd-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontEndTraffic.id]
  subnets            = [module.pub_sub_1.puplic_subnet_id_1, module.pub_sub_2.puplic_subnet_id_1]
  enable_deletion_protection = false
  tags = {
    Environment = "production"
  }
  provisioner "local-exec" {
    command = "echo  LB Puplic DNS:  ${self.dns_name} >> all_ips.txt"
  }
  
}
resource "aws_lb_target_group" "FE_TG" {
  name     = "FrontEnd-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.project_vpc-id
}
resource "aws_lb_target_group_attachment" "FE_TG_ATTACH" {
  depends_on = [ module.proxy_instance.instance_id ]
  target_group_arn = aws_lb_target_group.FE_TG.arn
  target_id        = module.proxy_instance.instance_id
  port             = 80
}
resource "aws_lb_target_group_attachment" "FE_TG_ATTACH_2" {
  depends_on = [ module.proxy_instance2.instance_id ]
  target_group_arn = aws_lb_target_group.FE_TG.arn
  target_id        = module.proxy_instance2.instance_id 
  port             = 80
}
resource "aws_lb_listener" "FE_L" {
  load_balancer_arn = aws_lb.FE_LB.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.FE_TG.arn
  }
}