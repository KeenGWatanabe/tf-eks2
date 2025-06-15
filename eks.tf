module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.name_prefix}-eks-cluster"
  cluster_version = "1.32"
  enable_irsa     = true  # ← This enables automatic IRSA setup

  cluster_addons = {
    aws-load-balancer-controller = {
      resolve_conflicts        = "OVERWRITE"
      service_account_name     = "aws-load-balancer-controller"  # Explicit name
      most_recent              = true  # Recommended
      configuration_values = {
        enableShield           = false  # Customize controller settings
        enableWaf             = false
      }
    }
  }

  eks_managed_node_groups = {
    taskmgr = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }


  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public_subnet.*.id
  # subnet_ids = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)  # ← ALB needs both

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}