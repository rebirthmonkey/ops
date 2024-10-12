terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//security-group?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix

  well-known-cidrs = [
    # 公司出口 IP 段，如果用其他地址访问，请先找到出口 IP ，加入到这个列表里
    "61.135.194.0/24",
    "111.206.145.0/24",
    "59.152.39.0/24",
    "180.78.55.0/24",
    "111.206.94.0/24",
    "111.206.96.0/24",
  ]
  well-known-ports = [
    "80", "443"
  ]
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  security_groups = {
    well-known = {
      name = "${local.prefix}-well-known"
      ingress = concat(
        [
          {
            action      = "ACCEPT"
            cidr_block  = local.env_vars.network.vpc_cidr # var.consul_private_network_source_ranges
            protocol    = "TCP" # "TCP"  # TCP, UDP and ICMP
            port        = "ALL" # "80-90" # 80, 80,90 and 80-90
            description = ""
          }
        ],
        [
          for cidr in local.well-known-cidrs: {
          action      = "ACCEPT"
          cidr_block  = cidr # var.consul_private_network_source_ranges
          protocol    = "TCP" # "TCP"  # TCP, UDP and ICMP
          port        = "ALL" # "80-90" # 80, 80,90 and 80-90
          description = ""
        }
        ], [
          for port in local.well-known-ports: {
            action      = "ACCEPT"
            cidr_block  = "0.0.0.0/0" # var.consul_private_network_source_ranges
            protocol    = "TCP" # "TCP"  # TCP, UDP and ICMP
            port        = port # "80-90" # 80, 80,90 and 80-90
            description = ""
          }
        ])
    }
  }
}
