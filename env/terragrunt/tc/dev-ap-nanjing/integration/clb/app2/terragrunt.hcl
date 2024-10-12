terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//clb?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix

  master_zone_id   = local.env_vars.network.availability_zones[0]
  slave_zone_id    = local.env_vars.network.availability_zones[2]
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path  = "../../network/vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

dependency "sg" {
  config_path  = "../../security-group/all"
  mock_outputs = {
    sg_ids = {

    }
  }
}

inputs = {
  clb_name                     = "${local.prefix}-app2"
  clb_tags                     = local.tags
  network_type                 = "OPEN" // 'OPEN' and 'INTERNAL'
  vpc_id                       = dependency.vpc.outputs.vpc_id
  security_groups              = [try(dependency.sg.outputs.ids["${local.prefix}-well-known"], "")]
  create_clb_log               = false
  dynamic_vip                  = true
  address_ip_version           = "ipv4" // pv4, ipv6 and IPv6FullChain.
  internet_bandwidth_max_out   = 100 // [1, 2048]
  internet_charge_type         = "TRAFFIC_POSTPAID_BY_HOUR"
  //  TRAFFIC_POSTPAID_BY_HOUR, BANDWIDTH_POSTPAID_BY_HOUR and BANDWIDTH_PACKAGE.
  load_balancer_pass_to_target = true
  master_zone_id               = local.master_zone_id
  slave_zone_id                = local.slave_zone_id
  tags                         = local.tags
  create_listener              = false
#  clb_listeners                = [
#    {
#      listener_name = "http_listener"
#      protocol      = "HTTP"
#      port          = 80
#    },
#  ]
  create_listener_rules = false
#  clb_listener_rules    = [
#    {
#      listener_index = 0
#      domain         = local.parent_vars.locals.domains.app2
#      url            = "/"
#    },
#  ]
}
