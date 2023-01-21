/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

locals {
  kubeconfig_filename = "work/kubeconfig.yaml"
  map_roles           = join("", data.template_file.map_roles[*].rendered)
}

