terraform {
  source = "tfr://registry.terraform.io/terraform-tencentcloud-modules/vpc/tencentcloud?version=1.1.0"
}

locals {
#  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags = merge(local.global_vars.tags, {})
  sub_paths = split("/", path_relative_to_include())
  product = element(local.sub_paths, length(local.sub_paths) - 2)
  sub_product = element(local.sub_paths, length(local.sub_paths) - 1)
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path  = "../vpc"
}

inputs = {
  create_vpc  = false
  vpc_id = dependency.vpc.outputs.vpc_id
  tags = dependency.vpc.outputs.tags

  availability_zones = local.env_vars.network.availability_zones
  subnet_name  = local.sub_product
  subnet_cidrs = local.env_vars.network["${local.sub_product}_cidrs"]

  subnet_tags = local.tags
}
