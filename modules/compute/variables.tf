variable "public_subnet" {
  description = "ID of the public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "IP address allowed to SSH into instances"
  type        = string
}