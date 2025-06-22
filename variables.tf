variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "MONGODB_URI" {
  description = "MongoDB Atlas connection URI"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the EKS cluster"
  type        = list(string)
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}


variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
  
}