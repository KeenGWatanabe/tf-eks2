variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "custom" # Change to your preferred prefix  
}
variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "custom-cluster" # Change to your preferred cluster name
}