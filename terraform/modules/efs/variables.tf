# efs variables

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "private_app_subnet_ids" {
  description = "private data subnet cidr"
  type = list(string)
}

variable "wordpress_sg_id" {
  type = string
}


