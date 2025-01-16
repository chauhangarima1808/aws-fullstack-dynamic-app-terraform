output "dns_name" {
  value = aws_efs_file_system.wordpress.dns_name
}

output "mount_target_dns_names" {
  value = aws_efs_mount_target.wordpress[*].dns_name
}

output "efs_security_group" {
  value = aws_security_group.efs.id
}

output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}