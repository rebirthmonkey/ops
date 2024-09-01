locals {
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

  default_sg_id = module.security_group.ids["${local.prefix}-well-known"]

}

module "security_group" {
  source = "../../modules/security_groups"
  security_groups = {
    well-known = {
      name = "${local.prefix}-well-known"
      ingress = concat(
        [
          {
            action      = "ACCEPT"
            cidr_block  = local.vpc_cidr # var.consul_private_network_source_ranges
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
