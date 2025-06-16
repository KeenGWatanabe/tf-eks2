To clean up AWS-EKS resources created by Terraform, follow these steps carefully:

### 1. This will delete resources in the correct dependency order.
For EKS clusters:
```bash
aws eks list-nodegroups --cluster-name taskmgr-eks-cluster
aws eks delete-nodegroup --cluster-name taskmgr-eks-cluster --nodegroup-name taskmgr-20250615233013820600000001
```
wait awhile for deletion to take effect
```bash
aws eks delete-cluster --name taskmgr-eks-cluster

terraform destroy
```
-----------------------------------------------------------------------------------
### 2. **Targeted Cleanup**
For partial cleanup:
```bash
# Destroy specific resources
terraform destroy -target=aws_instance.web_server
terraform destroy -target=module.vpc
```

### 3. **When Standard Destroy Fails**
#### A. Orphaned Resources
```bash
# Find resources not tracked in state
aws resourcegroupstaggingapi get-resources --tag-filters Key=terraform,Values=true

# Manually delete them via AWS CLI
aws ec2 terminate-instances --instance-ids i-1234567890
```

#### B. Stuck Deletions
For EKS clusters:
```bash
aws eks list-nodegroups --cluster-name taskmgr-eks-cluster
aws eks delete-nodegroup --cluster-name taskmgr-eks-cluster --nodegroup-name taskmgr-20250615233013820600000001
```
wait awhile for deletion to take effect
```bash
aws eks delete-cluster --name taskmgr-eks-cluster

terraform destroy -target=aws_eks_node_group.<your_node_group_resource_name>
```

### 4. **Complete Cleanup**
```bash
# Remove Terraform state and cache
rm -rf .terraform* terraform.tfstate*

# Delete S3 backend (if used)
aws s3 rb s3://my-terraform-state --force
```

### 5. **AWS-Specific Cleanup**
#### Common Orphaned Resources:
```bash
# Find and delete unattached EBS volumes
aws ec2 describe-volumes --filters Name=status,Values=available | jq '.Volumes[].VolumeId' | xargs -I{} aws ec2 delete-volume --volume-id {}

# Delete stray ENIs
aws ec2 describe-network-interfaces --filters Name=status,Values=available | jq '.NetworkInterfaces[].NetworkInterfaceId' | xargs -I{} aws ec2 delete-network-interface --network-interface-id {}

# Cleanup CloudWatch Log Groups
aws logs describe-log-groups --query 'logGroups[?starts_with(logGroupName,`/aws/eks`)].logGroupName' | jq -r '.[]' | xargs -I{} aws logs delete-log-group --log-group-name {}
```

### 6. **Prevention Tips**
```hcl
# Always add these to your Terraform config
resource "aws_instance" "example" {
  # ...
  lifecycle {
    prevent_destroy = false # Set to true for critical resources
  }
}
```

### Verification
After destruction:
```bash
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value]'
aws eks list-clusters
aws rds describe-db-instances
```

### Notes:
1. Some resources (like S3 buckets) must be emptied before deletion
2. AWS sometimes takes 15-30 minutes to fully clean up dependencies
3. For production environments, consider:
   ```bash
   terraform destroy -var 'environment=prod' -lock=false
   ```

Would you like me to generate a destruction checklist specific to your resources? I can analyze your state file to provide a tailored cleanup plan.

# Delete EKS Cluster and Node Groups
aws eks list-clusters | jq -r '.clusters[]' | xargs -I{} aws eks delete-cluster --name {}

# Delete ALL resources tagged with Terraform (DANGEROUS)
aws resourcegroupstaggingapi get-resources --tag-filters Key=terraform,Values=true \
  --query 'ResourceTagMappingList[].ResourceARN' --output text | \
  xargs -n1 aws resourcegroupstaggingapi untag-resources --resource-arn-list

# Delete remaining VPC components
aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text | \
  xargs -I{} aws ec2 delete-vpc --vpc-id {}