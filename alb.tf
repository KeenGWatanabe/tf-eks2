
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1" # Chart version

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

  set {
    name  = "region"
    value = "us-east-1" # Your region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id # Ensure this variable is defined in your variables.tf
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.eks.cluster_iam_role_arn # Or your custom IRSA role ARN
  }
  
  depends_on = [
    module.eks,
    module.eks.eks_managed_node_groups,
    
  ]
  
}


