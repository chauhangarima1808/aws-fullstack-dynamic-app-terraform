# environment variables
aws_region = "us-east-1"
project_name = "wordpress"
vpc_cidr="10.0.0.0/16"
azs=["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
private_app_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
private_data_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24"]
db_instance_class = "db.t3.micro"
db_name = "wordpressdb"
ami_id = "ami-01816d07b1128cd2d" # Amazon Linux 2 AMI ID
instance_type   = "t2.micro"
asg_desired_capacity = 1
asg_max_size = 1
asg_min_size = 1




