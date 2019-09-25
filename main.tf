/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

locals {
  tags = {
    Terraform = "true"
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.this.arn

  version = var.cluster_version

  vpc_config {
    security_group_ids = [join("", aws_security_group.this.*.id)]
    subnet_ids         = var.subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy,
  ]

  enabled_cluster_log_types = var.enabled_cluster_log_types

  lifecycle {
    prevent_destroy = true
  }
}

