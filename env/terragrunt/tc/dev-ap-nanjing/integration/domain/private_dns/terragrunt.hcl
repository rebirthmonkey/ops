terraform {
#   source = "${get_path_to_repo_root()}/10_tencent/modules/private-dns"
  source = "git::https://github.com/rebirthmonkey/terraform.git//private-dns?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path  = "../../network/vpc"
}

dependency "cdb" {
  config_path  = "../../databases/cdb"
}

dependency "redis" {
  config_path  = "../../databases/redis"
}

inputs = {
  create_private_dns = true
  domain             = local.parent_vars.locals.db_private_domain

  vpc_sets = [
    {
      region      = local.parent_vars.locals.region
      uniq_vpc_id = dependency.vpc.outputs.vpc_id
    }
  ]

  dns_forward_status = "ENABLED"
  tags               = local.tags

  records = {
    "cdb" = {
      sub_domain   = "mysql"
      record_type  = "A"
      record_value = dependency.cdb.outputs.intranet_ip
      ttl          = 600
    }
    "redis" = {
      sub_domain   = "redis"
      record_type  = "A"
      record_value = dependency.redis.outputs.ip.default
      ttl          = 600
    }
  }
}
