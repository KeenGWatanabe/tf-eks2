variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "taskmgr" # Change to your preferred prefix  
}
variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "taskmgr-cluster" # Change to your preferred cluster name
}