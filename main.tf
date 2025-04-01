terraform {
  backend "s3" {
    bucket         = "tf-state-210895"
    key = "dev/terraform.tfstate"
    region         = "ap-south-1"
    # use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.kubernetes.cluster_endpoint
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

module "networking" {
  source          = "./modules/networking"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  region          = var.region
  allowed_ssh_ip  = var.allowed_ssh_ip
}

module "compute" {
  source         = "./modules/compute"
  public_subnet  = module.networking.public_subnet_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  vpc_id         = module.networking.vpc_id
  allowed_ssh_ip = var.allowed_ssh_ip
}

module "kubernetes" {
  source         = "./modules/kubernetes"
  private_subnet = module.networking.private_subnet_id
  public_subnet  = module.networking.public_subnet_id
  vpc_id         = module.networking.vpc_id
  cluster_name   = var.cluster_name
  node_type      = var.node_type
}

module "storage" {
  source      = "./modules/storage"
  bucket_name = var.bucket_name
}