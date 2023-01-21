/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

data "aws_iam_policy_document" "assume_cluster_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name        = "eks-cluster-${var.name}"
  description = "Used for managing the EKS cluster"

  assume_role_policy = data.aws_iam_policy_document.assume_cluster_role.json

  tags = merge(var.tags, local.tags)
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.this.name
}

// Global cluster admins role
data "aws_iam_policy_document" "account_assume_cluster_admin_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::${var.cluster_admin_account_id}:root"]
    }
  }
}

resource "aws_iam_role" "cluster_admin" {
  name        = var.global_cluster_admin_role
  description = "Used for granting access to the EKS cluster for admins"

  assume_role_policy = data.aws_iam_policy_document.account_assume_cluster_admin_role.json

  tags = merge(var.tags, local.tags)
}

// Workers role
data "aws_iam_policy_document" "assume_workers_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workers" {
  name        = "eks-workers-${var.name}"
  description = "Allows EKS worker nodes to interact with AWS"

  assume_role_policy = data.aws_iam_policy_document.assume_workers_role.json

  tags = merge(var.tags, local.tags)
}

resource "aws_iam_role_policy_attachment" "eks_workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = join("", aws_iam_role.workers[*].name)
}

resource "aws_iam_role_policy_attachment" "eks_workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.workers[*].name)
}

resource "aws_iam_role_policy_attachment" "eks_workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.workers[*].name)
}

resource "aws_iam_role_policy_attachment" "eks_workers_AmazonCWAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = join("", aws_iam_role.workers[*].name)
}

resource "aws_iam_instance_profile" "workers" {
  name = "eks-workers-${var.name}"
  role = join("", aws_iam_role.workers[*].name)
}

// Workers autoscaling
data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-workers-autoscaling-${var.name}"
  description = "EKS worker node autoscaling policy for cluster ${var.name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = aws_iam_role.workers.name
}

// Route53
data "aws_iam_policy_document" "dns_management" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "dns_management" {
  name_prefix = "eks-workers-dns-${var.name}"
  description = "EKS worker node can manage Route 53 for cluster ${var.name}"
  policy      = data.aws_iam_policy_document.dns_management.json
}

resource "aws_iam_role_policy_attachment" "dns_management" {
  policy_arn = aws_iam_policy.dns_management.arn
  role       = aws_iam_role.workers.name
}
