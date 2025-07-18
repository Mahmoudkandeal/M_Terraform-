resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  tags = {
    Name = var.instance_name
  }
  provisioner "file" {
    source      = var.flask_app_path
    destination = "/home/ec2-user/cuteblog-flask"
    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = self.private_ip
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }
  provisioner "file" {
    source      = var.setup_script_path
    destination = "/tmp/script.sh"
    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = self.private_ip
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args"
    ]
    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = self.private_ip
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }
  provisioner "local-exec" {
    command = "echo private ip ${self.private_ip} >> all_ips.txt"
  }
}
