/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

data "aws_caller_identity" "current" {}

resource "local_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = local.kubeconfig_filename

  depends_on = [aws_eks_cluster.this]
}

