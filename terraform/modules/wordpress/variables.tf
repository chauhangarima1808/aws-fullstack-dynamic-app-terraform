# instance variables

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "efs_dns_name" {
  type = string
}

variable "efs_mount_target" {
  type = list(string)
}

variable "efs_id" {
  type = string
}

variable "ssh_ip" {
  type    = string
}

variable "rds_endpoint" {
  type = string
}

variable "rds_security_group" {
  type = string
}

variable "efs_security_group" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "ami_id" {
  type    = string
}

variable "instance_type" {
  type    = string
}

variable "asg_desired_capacity" {
  type    = number
}

variable "asg_max_size" {
  type    = number
}

variable "asg_min_size" {
  type    = number
}