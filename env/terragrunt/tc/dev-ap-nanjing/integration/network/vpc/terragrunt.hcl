terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//vpc?ref=main"
}

locals {
#  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags = merge(local.global_vars.tags, {})
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_name = local.env_vars.network.vpc_name
  vpc_cidr = local.env_vars.network.vpc_cidr
  vpc_is_multicast = true
  vpc_tags = local.tags

  enable_nat_gateway = true
  destination_cidrs  = ["0.0.0.0/0"]
  next_type          = ["NAT"]
  next_hub           = ["0"]
}
