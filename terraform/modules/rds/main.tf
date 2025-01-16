resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids =  var.subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds_db_security_group" {
  name        = "${var.project_name}-rds-sg"
  description = "enable mysql/aurora access on port 3306"
  vpc_id      = var.vpc_id

  ingress {
    description      = "mysql/aurora access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.wordpress_sg_id]
  }

  ingress {
    description      = "custom access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [var.bastion_sg_id]
  }

  ingress {
    description      = "custom access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks     = ["10.0.0.63/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "mysql"
  engine_version      = "8.0.39"
  instance_class      = var.instance_class
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible    = false

  vpc_security_group_ids = [aws_security_group.rds_db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  multi_az = true

  tags = {
    Name        = "${var.project_name}-db"
  }
}