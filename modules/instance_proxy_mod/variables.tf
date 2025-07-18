variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "private_key_path" {}
variable "script_source" {}
variable "backend_dns" {}

variable "keypair_dependency" {
  description = "Keypair resource to enforce creation order"
}

variable "backend_lb_dependency" {
  description = "Backend LB resource to enforce creation order"
}
variable "instance_name" {
  default = "Proxy Server"
}
