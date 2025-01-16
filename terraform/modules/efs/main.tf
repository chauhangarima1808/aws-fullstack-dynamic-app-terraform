resource "aws_efs_file_system" "wordpress" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true

  tags = {
    Name        = "${var.project_name}-efs"
  }
}

resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.wordpress_sg_id]
  }

  tags = {
    Name        = "${var.project_name}-efs-sg"
  }
}

resource "aws_efs_mount_target" "wordpress" {
  count           = length(var.private_app_subnet_ids)
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = var.private_app_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}