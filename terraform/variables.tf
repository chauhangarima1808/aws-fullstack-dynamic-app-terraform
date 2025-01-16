variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# vpc variables
variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
}

variable "azs" {
  description = "availability zones"
  type = list(string)
}

variable "public_subnet_cidrs" {
  description = "public subnet cidr"
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "private app subnet cidr"
  type = list(string)
}

variable "private_data_subnet_cidrs" {
  description = "private data subnet cidr"
  type = list(string)
}

# rds variables
variable "db_instance_class" {
  description = "DB Instance class"
  type = string
}

variable "db_name" {
  description = "DB name"
  type = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "ssh_ip" {
  description = "SSH ip"
  type        = string
}

# instance variables
variable "ami_id" {
  description = "AMI Id"
  type    = string
}

variable "instance_type" {
  description = "Instance type"
  type    = string
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type    = number
}

variable "asg_max_size" {
  description = "ASG max size"
  type    = number
}

variable "asg_min_size" {
  description = "ASG min size"
  type    = number
}