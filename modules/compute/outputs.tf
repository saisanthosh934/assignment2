output "instance_public_ip" {
  description = "Public IP address of the Ubuntu instance"
  value       = aws_instance.ubuntu.public_ip
}

output "instance_id" {
  description = "ID of the Ubuntu instance"
  value       = aws_instance.ubuntu.id
}