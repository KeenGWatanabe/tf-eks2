terraform {
  backend "s3" {
    bucket         = "secrets.tfstate-backend.com"  # Must match the bucket name above
    key            = "secrets-eks/terraform.tfstate"        # State file path
    region         = "us-east-1"                # Same as provider
    dynamodb_table = "secrets-terraform-state-locks"    # If using DynamoDB
    # use_lockfile   = true                       # replaces dynamodb_table
    encrypt        = true                       # Use encryption
  }
}

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
  vpc_id     = var.vpc_id
  # subnet_ids = aws_subnet.public_subnet[*].id  # ← Use public subnets for ALB
  #######new addtions############### ln 35-51
  subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids) # ← ALB needs both

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


# Note: Ensure the AWS Load Balancer Controller version matches your EKS version
# eks 1.29 = alb_ctrl 1.7.x
# eks 1.32 = alb_ctrl 1.8.x