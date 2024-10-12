terraform {
#   source = "${get_path_to_repo_root()}/10_tencent/modules/dns"
  source = "git::https://github.com/rebirthmonkey/terraform.git//public-dns?ref=main"
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

dependency "clb-frontend" {
  config_path  = "../../clb/frontend"
  mock_outputs = {
    clb_domain = ""
  }
}

inputs = {
  domain = "${local.parent_vars.locals.public_domain}"
  records = {
    frontend = {
      record_type = "CNAME"
#       record_line = "${local.parent_vars.locals.record_line}"
      record_line = "默认"
      value       = format("%s.", "${dependency.clb-frontend.outputs.clb_domain}")
      sub_domain  = "${local.parent_vars.locals.sub_domains.frontend}"
      mx          = null
      ttl         = 600
      status      = "ENABLE"
    }
  }
}