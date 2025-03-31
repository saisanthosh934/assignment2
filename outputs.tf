output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.networking.private_subnet_id
}

output "instance_public_ip" {
  description = "Public IP address of the Ubuntu instance"
  value       = module.compute.instance_public_ip
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.kubernetes.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubectl config file contents"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.storage.bucket_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value       = module.kubernetes.cluster_certificate_authority_data
}