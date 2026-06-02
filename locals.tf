/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

locals {
  kubeconfig_filename = "work/kubeconfig.yaml"
  map_roles = templatefile("${path.module}/templates/config_map_aws_map_roles.yaml.tpl",
  {
    map_roles = var.map_roles
  })
  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl",
  {
    server                     = aws_eks_cluster.this.endpoint
    certificate_authority_data = aws_eks_cluster.this.certificate_authority[0].data
    cluster_name               = var.name
    aws_role = format(
      "arn:aws:iam::%s:role/%s",
      data.aws_caller_identity.current.account_id,
      var.aws_role_name,
    )
    aws_profile = var.aws_profile_name
  })
}

