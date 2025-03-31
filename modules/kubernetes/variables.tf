variable "private_subnet" {
  description = "ID of the private subnet"
  type        = string
}

variable "public_subnet" {
  description = "ID of the public subnet"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
}