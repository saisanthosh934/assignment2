output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "kubeconfig" {
  description = "Kubectl config file contents"
  value       = <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority[0].data}
    server: ${aws_eks_cluster.cluster.endpoint}
  name: ${aws_eks_cluster.cluster.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.cluster.name}
    user: ${aws_eks_cluster.cluster.name}
  name: ${aws_eks_cluster.cluster.name}
current-context: ${aws_eks_cluster.cluster.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.cluster.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${aws_eks_cluster.cluster.name}"
EOF
  sensitive = true
}

output "cluster_token" {
  description = "Token for EKS cluster"
  value       = data.aws_eks_cluster_auth.cluster.token
  sensitive   = true
}