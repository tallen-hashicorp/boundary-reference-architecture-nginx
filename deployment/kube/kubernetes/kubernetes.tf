# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "kubernetes" {
  config_context_cluster = "docker-desktop"
  config_path            = "~/.kube/config"
}
