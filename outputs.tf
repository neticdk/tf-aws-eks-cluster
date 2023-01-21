/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

output "security_group_id" {
  value = join("", aws_security_group.this[*].id)
}

output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = join("", aws_eks_cluster.this[*].id)
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = join("", aws_eks_cluster.this[*].arn)
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = join("", aws_eks_cluster.this[*].endpoint)
}

output "eks_cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = join("", aws_eks_cluster.this[*].version)
}

output "kubeconfig" {
  description = "`kubeconfig` configuration to connect to the cluster using `kubectl`."
  value       = join("", data.template_file.kubeconfig[*].rendered)
}

output "kubeconfig_path" {
  description = "Where kubeconfig exists"
  value       = local_file.kubeconfig.filename
}

output "cluster_admin_arn" {
  description = "ARN of the EKS cluster admin role"
  value       = aws_iam_role.cluster_admin.arn
}

output "iam_role_name_workers" {
  description = "IAM role name for EKS worker groups"
  value       = aws_iam_role.workers.name
}

output "instance_profile_name" {
  description = "Name of the instance profile created for the worker nodes"
  value       = join("", aws_iam_instance_profile.workers[*].name)
}

output "eks_cluster_oidc_url" {
  description = "The OIDC url for the EKS Cluster"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
