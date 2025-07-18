output "instance_id" {
  value = aws_instance.backend.id
}

output "private_ip" {
  value = aws_instance.backend.private_ip
}
