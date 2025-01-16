terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket         = "terraform-state-wordpress-web-application"
    key            = "environment/global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-wordpress-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name  = var.project_name
  vpc_cidr      = var.vpc_cidr
  azs           = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
  
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_data_subnet_ids
  instance_class = var.db_instance_class
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  wordpress_sg_id = module.wordpress.wordpress_sg_id
  bastion_sg_id = module.wordpress.bastion_sg_id
}

# EFS Module
module "efs" {
  source = "./modules/efs"

  project_name  = var.project_name
  vpc_id     = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  wordpress_sg_id = module.wordpress.wordpress_sg_id
}

# Wordpress Module
module "wordpress" {
  source = "./modules/wordpress"
  
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnet_ids
  private_subnets  = module.vpc.private_app_subnet_ids
  efs_dns_name     = module.efs.dns_name
  efs_mount_target = module.efs.mount_target_dns_names
  rds_endpoint     = module.rds.endpoint
  rds_security_group = module.rds.rds_security_group
  efs_security_group = module.efs.efs_security_group
  efs_id            = module.efs.efs_id
  db_name          = var.db_name
  db_user          = var.db_username
  db_password      = var.db_password
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size = var.asg_max_size
  asg_min_size = var.asg_min_size
  ssh_ip = var.ssh_ip
}



