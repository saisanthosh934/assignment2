variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "node_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t2.large"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "IP address allowed to SSH into instances"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "prod-cluster"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "jigalala1234"
}