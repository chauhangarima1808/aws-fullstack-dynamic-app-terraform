variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  default     = "terraform-state-wordpress-web-application"
}

variable "table_name" {
  description = "The name of the Dynamo]DB table. Must be unique in this AWS account."
  type        = string
  default     = "terraform-state-wordpress-lock"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}