/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

resource "aws_security_group" "this" {
  name        = "eks-cluster-${var.name}"
  description = "Security Group for EKS Cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = "eks-cluster-${var.name}"
    },
    var.tags,
    local.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress" {
  description = "Allow all egress from cluster"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  type        = "egress"

  security_group_id = join("", aws_security_group.this.*.id)
}

resource "aws_security_group_rule" "ingress_workers" {
  count                    = var.workers_security_group_count
  description              = "Allow the cluster to receive communication from the worker nodes"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = element(var.workers_security_group_ids, count.index)
  security_group_id        = join("", aws_security_group.this.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.allowed_security_groups_count
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.this.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.this.*.id)
  type              = "ingress"
}
