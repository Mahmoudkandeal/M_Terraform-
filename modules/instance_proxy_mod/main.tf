
resource "aws_instance" "proxy" {
  depends_on             = [var.keypair_dependency]
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
  }

  provisioner "file" {
    source      = var.script_source
    destination = "/tmp/script.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    command = "echo public ip is: ${self.public_ip} >> all_ips.txt"
  }
}

resource "null_resource" "nginx_setup" {
  provisioner "remote-exec" {
    inline = [
      "echo \"export BACKEND_IP=${var.backend_dns}\" | sudo tee /etc/profile.d/backend_ip.sh",
      "sudo chmod +x /etc/profile.d/backend_ip.sh",
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh ${var.backend_dns}"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.proxy.public_ip
    }
  }

  depends_on = [
    aws_instance.proxy,
    var.backend_lb_dependency
  ]
}
