locals {
  terraform_tencentcloud_plugin_version = "1.81.130"
  tencentcloud_api_domain = "internal.tencentcloudapi.com" # only use this in Singapore Office. default: tencentcloudapi.com
  region = "ap-nanjing"
  owner = "ops"

  // Naming Convention
  prefix = "ops"

  env_vars = yamldecode(file("env.yaml")) # this is just to show how to use a separate var file. The variables in that file can be extracted here, too.

  global = {
    tags = {
      create_by: "terraform",
      owner: local.owner
    }
  }

  db_private_domain = "${local.prefix}-overseasops.com"  # DB private domain name
  db_password = "P@ssw0rd"

  public_domain = "overseasops.com"
  sub_domains = {
    frontend = "${local.prefix}-frontend-${local.region}"
    app1 = "${local.prefix}-app1-${local.region}"
    app2 = "${local.prefix}-app2-${local.region}"
  }
  domains = {
    frontend = "${local.sub_domains.frontend}.${local.public_domain}"
    app1 = "${local.sub_domains.app1}.${local.public_domain}"
    app2 = "${local.sub_domains.app2}.${local.public_domain}"
  }

  app_vars = {
    frontend = {
      COS_BUCKET  = "ruan-1251956900"
      COS_REGION  = "ap-guangzhou"
      COS_PATH    = "/webapp"
      APP1_DOMAIN = local.domains.app1
      APP2_DOMAIN = local.domains.app2
    }
    app1 = {
      COS_BUCKET     = "ruan-1251956900"
      COS_REGION     = "ap-guangzhou"
      COS_PATH       = "/app1"
      PRIVATE_DOMAIN = local.db_private_domain
      DB_PASSWORD    = local.db_password
    }
  }
}

# Here we generate backend.tf for each of the modules without editing them one by one
remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
#  backend = "cos"
#  config = {
#    region = "${local.backend_region}"
#    bucket = "${local.backend_bucket}"
#    prefix = "projects/${local.customer}/${local.project}/${local.backend_region_prefix}-${local.region}/terraform-${path_relative_to_include()}/state"
#    secret_id = "${local.backend_secret_id}"
#    secret_key = "${local.backend_secret_key}"
#    security_token = "${local.backend_security_token}"
#  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "tencentcloud" {
    region = "${local.region}"
    domain = "${local.tencentcloud_api_domain}"
}
EOF
}

# Here  we generate version.tf for each of the modules without editing them one by one
generate "terraform" {
  path      = "version.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= ${local.terraform_tencentcloud_plugin_version}"
    }
  }
}
EOF
}