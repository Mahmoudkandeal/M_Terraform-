variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "private_key_path" {}

variable "flask_app_path" {
  description = "Path to Flask app source folder"
}
variable "setup_script_path" {
  description = "Path to backend provisioning shell script"
}

variable "bastion_host" {
  description = "Public IP of the proxy instance"
}

variable "instance_name" {
  default = "BE WebServer"
}

