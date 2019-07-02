/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

data "aws_caller_identity" "current" {}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    server                     = join("", aws_eks_cluster.this.*.endpoint)
    certificate_authority_data = aws_eks_cluster.this.certificate_authority[0].data
    cluster_name               = var.name
    aws_role = format(
      "arn:aws:iam::%s:role/%s",
      data.aws_caller_identity.current.account_id,
      var.aws_role_name,
    )
    aws_profile = var.aws_profile_name
  }
}

resource "local_file" "kubeconfig" {
  content  = join("", data.template_file.kubeconfig.*.rendered)
  filename = local.kubeconfig_filename

  depends_on = [aws_eks_cluster.this]
}

