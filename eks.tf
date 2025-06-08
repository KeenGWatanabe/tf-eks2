module "eks" {
 source  = "terraform-aws-modules/eks/aws"
 version = "~> 20.31"

 cluster_name    = "${var.name_prefix}-eks-cluster"
 cluster_version = "1.32"
 enable_irsa = true
 # Optional
 cluster_endpoint_public_access = true

 # Optional: Adds the current caller identity as an administrator via cluster access entry
 enable_cluster_creator_admin_permissions = true

 eks_managed_node_groups = {
   rger = {
     min_size       = 1
     max_size       = 3
     desired_size   = 2
     
     instance_types = ["t3.medium"]
     capacity_type  = "ON_DEMAND"
   }
 }

 vpc_id     = aws_vpc.main.id
 subnet_ids = aws_subnet.public_subnet.*.id

 tags = {
   Environment = "dev"
   Terraform   = "true"
 }
}




# Then reference the OIDC provider like this:
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:default:app-service-account"]
    }
  }
}