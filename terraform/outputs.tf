output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.create_eip ? aws_eip.node_eip[0].public_ip : aws_instance.node_host.public_ip
}

output "ssh_private_key_path" {
  description = "Path to the generated private key"
  value       = local_file.private_key_pem.filename
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ${local_file.private_key_pem.filename} ubuntu@${var.create_eip ? aws_eip.node_eip[0].public_ip : aws_instance.node_host.public_ip}"
  sensitive   = true
}

output "vpc_id" {
  description = "Created VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Created public subnet ID"
  value       = aws_subnet.public.id
}

