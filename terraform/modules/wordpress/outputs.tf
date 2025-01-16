output "wordpress_sg_id" {
  value = aws_security_group.wordpress_webapp_security_group.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_security_group.id
}

