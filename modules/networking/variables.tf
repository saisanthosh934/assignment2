variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "IP address allowed to SSH into instances"
  type        = string
}