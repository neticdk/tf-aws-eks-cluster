/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

data "template_file" "map_roles" {
  count    = var.map_roles_count
  template = file("${path.module}/templates/config_map_aws_map_roles.yaml.tpl")

  vars = {
    role_arn = var.map_roles[count.index]["role_arn"]
    username = var.map_roles[count.index]["username"]
    group    = lookup(var.map_roles[count.index], "group", "system:authenticated")
  }
}

resource "kubernetes_config_map" "auth_config" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<ROLES
- rolearn: ${join("", aws_iam_role.workers[*].arn)}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${join("", aws_iam_role.cluster_admin[*].arn)}
  username: ${var.global_cluster_admin_role}
  groups:
    - system:masters
${local.map_roles}
    
ROLES

  }

  depends_on = [local_file.kubeconfig]
}

