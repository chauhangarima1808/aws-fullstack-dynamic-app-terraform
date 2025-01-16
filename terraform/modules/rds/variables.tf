#rds variables

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "wordpress_sg_id" {
  type = string
}

variable "bastion_sg_id" {
  type = string
}
