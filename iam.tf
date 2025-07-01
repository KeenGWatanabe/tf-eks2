data "aws_iam_policy_document" "eks_kms_permissions" {
  statement {
    actions = [
      "kms:CreateAlias",
      "kms:CreateKey",
      "kms:DescribeKey",
      "kms:ScheduleKeyDeletion",
      "kms:List*",
      "kms:Get*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "eks_cluster_permissions" {
  statement {
    actions = [
      "eks:CreateCluster",
      "eks:DescribeCluster",
      "eks:DeleteCluster",
      "eks:ListClusters",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:UpdateClusterConfig",
      "eks:CreateNodegroup",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:UpdateNodegroupConfig",
      "eks:DeleteNodegroup",
      "eks:ListUpdates",
      "eks:ListTagsForResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_kms_policy" {
  name        = "EKSKMSAccessPolicy"
  description = "Policy for EKS KMS access"
  policy      = data.aws_iam_policy_document.eks_kms_permissions.json
}

resource "aws_iam_policy" "eks_cluster_policy" {
  name        = "EKSClusterAccessPolicy"
  description = "Policy for EKS cluster management"
  policy      = data.aws_iam_policy_document.eks_cluster_permissions.json
}

# Attach these policies to your user/role
resource "aws_iam_user_policy_attachment" "kms_attach" {
  user       = "rger"
  policy_arn = aws_iam_policy.eks_kms_policy.arn
}

resource "aws_iam_user_policy_attachment" "eks_attach" {
  user       = "rger"
  policy_arn = aws_iam_policy.eks_cluster_policy.arn
}                                                                       