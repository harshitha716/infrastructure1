output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "The ID of the security group attached to the bastion host"
  value       = aws_security_group.bastion_sg.id
}