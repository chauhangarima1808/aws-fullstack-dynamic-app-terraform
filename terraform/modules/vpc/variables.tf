# vpc variables

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
}

variable "azs" {
  description = "availability zones"
  type    = list(string)
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