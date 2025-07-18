output "instance_id" {
  value = aws_instance.proxy.id
}

output "public_ip" {
  value = aws_instance.proxy.public_ip
}
