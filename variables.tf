/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map
  default     = {}
}

variable "name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cluster_version" {
  description = "Cluster Version"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "List of subnets to launch the cluster in"
  type        = list(string)
}

variable "workers_security_group_count" {
  description = "Number of security group ids"
  type        = number
}

variable "workers_security_group_ids" {
  description = "List of worker security group ids allowed to connect to the cluster"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of additoinal security group ids allowed to connect to the cluster"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups_count" {
  description = "Count of allowed security groups"
  type        = number
  default     = 0
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the cluster"
  type        = list(string)
  default     = []
}

variable "aws_role_name" {
  description = "AWS Role Name to use when calling kubectl"
  type        = string
  default     = "eks-global-cluster-admin"
}

variable "aws_profile_name" {
  description = "AWS Profile Name to use when calling kubectl"
  type        = string
  default     = "futadmin"
}

// IAM
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list(any)
  default     = []
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = number
  default     = 0
}

variable "cluster_admin_account_id" {
  description = "Account ID of account that needs to be trusted for assuming the cluster admin role"
  type        = string
}

variable "global_cluster_admin_role" {
  description = "Name of IAM role that will be added to the system:masters group"
  type        = string
  default     = "eks-global-cluster-admin"
}

variable "enabled_cluster_log_types" {
  description = "EKS logs to send to CloudWatch"
  type        = list(string)
  default     = []
}
