terraform {
  backend "s3" {
    bucket         = "thunder.tfstate-backend.com"  # Must match the bucket name above
    key            = "thunder-eks/terraform.tfstate"        # State file path
    region         = "us-east-1"                # Same as provider
    dynamodb_table = "thunder-terraform-state-locks"    # If using DynamoDB
    # use_lockfile   = true                       # replaces dynamodb_table
    encrypt        = true                       # Use encryption
    acl            = "bucket-owner-full-control" # Optional, for cross-account access
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.name_prefix}-eks-cluster"
  cluster_version = "1.29"
  enable_irsa     = true  # ← This enables automatic IRSA setup


  # VPC configuration
  vpc_id     = aws_vpc.main.id
  #######new addtions############### ln 35-51
  subnet_ids = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)  # ← ALB needs both
  
  # Endpoint access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  
  # Node groups
  eks_managed_node_groups = {
    thunder = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
  #  # Security group configuration
  # cluster_security_group_additional_rules = {
  #   ingress_all = {
  #     description = "Cluster API access"
  #     protocol    = "tcp"
  #     from_port   = 443
  #     to_port     = 443
  #     type        = "ingress"
  #     cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  #   }
  # }
 #######new addtions###############
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}



# Note: Ensure the AWS Load Balancer Controller version matches your EKS version
# eks 1.29 (ln6) = alb_ctrl 1.7.x (ln54)
# eks 1.32 (ln6) = alb_ctrl 1.8.x (ln54)