output "endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_security_group" {
  value = aws_security_group.rds_db_security_group.id
}