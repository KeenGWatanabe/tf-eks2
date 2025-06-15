output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn #aws_iam_openid_connect_provider.eks_oidc.arn
}

# Add these outputs to your tf-eks2/outputs.tf file (or create it if it doesn't exist)

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "The OIDC Provider"
  value       = module.eks.oidc_provider
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}