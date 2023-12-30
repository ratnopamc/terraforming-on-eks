variable "region" {
  description = "region"
  default     = "us-west-2"
  type        = string
}

variable "cluster_name" {
  default = "eks-karpenter"
}