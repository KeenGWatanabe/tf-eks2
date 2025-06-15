module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.name_prefix}-eks-cluster"
  cluster_version = "1.29"
  enable_irsa     = true  # ← This enables automatic IRSA setup

  # cluster_addons = {
  #   aws-load-balancer-controller = {
  #     most_recent              = true  # Recommended
  #     resolve_conflicts        = "OVERWRITE"
  #     service_account_name     = "aws-load-balancer-controller"  # Explicit name
  #     configuration_values = jsonencode({
  #       enableShield           = false  # Customize controller settings
  #       enableWaf             = false
  #     })
  #   }
  # }

  eks_managed_node_groups = {
    taskmgr = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # VPC configuration
  vpc_id     = aws_vpc.main.id
  # subnet_ids = aws_subnet.public_subnet[*].id  # ← Use public subnets for ALB
  #######new addtions############### ln 35-51
  subnet_ids = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)  # ← ALB needs both
  
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
   # Security group configuration
  cluster_security_group_additional_rules = {
    ingress_all = {
      description = "Cluster API access"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
    }
  }
 #######new addtions###############
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}



resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1" # Chart version

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
      name  = "serviceAccount.create"
      value = "false"
    }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    module.eks,
    module.eks.eks_managed_node_groups # Wait for nodes too
  ]
  
}

# Note: Ensure the AWS Load Balancer Controller version matches your EKS version
# eks 1.29 = alb_ctrl 1.7.x
# eks 1.32 = alb_ctrl 1.8.x