output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn #aws_iam_openid_connect_provider.eks_oidc.arn
}

# use this output for k8s service-account.yaml ln6 deployment.