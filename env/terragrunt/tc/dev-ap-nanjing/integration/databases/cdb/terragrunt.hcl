terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//cdb?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix

  # cdb
  mysql_password      = local.parent_vars.locals.db_password
  availability_zone   = local.env_vars.network.availability_zones[0]
  first_slave_zone    = local.env_vars.network.availability_zones[2]
  mysql_intranet_port = 3306
  db_name             = "ops"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path  = "../../network/vpc"
}

dependency "subnet" {
  config_path  = "../../network/db_subnet"
}

dependency "sg" {
  config_path  = "../../security-group/all"
}

inputs = {
  instance_name     = "${local.prefix}"
  engine_version    = "8.0"
  device_type       = "UNIVERSAL"
  mem_size          = 8000
  cpu               = 4
  volume_size       = 25
  parameters        = {}
  root_password     = local.mysql_password
  availability_zone = local.availability_zone
  first_slave_zone  = local.first_slave_zone
  slave_sync_mode   = 0 # 0 - Async replication; 1 - Semisync replication; 2 - Strongsync replication.
  slave_deploy_mode = 1 # 0 - Single availability zone; 1 - Multiple availability zones.
  internet_service  = 0
  intranet_port     = local.mysql_intranet_port
  vpc_id            = dependency.vpc.outputs.vpc_id
  subnet_id         = dependency.subnet.outputs.subnet_id[0]
  charge_type       = "POSTPAID"
  prepaid_period    = null
  auto_renew_flag   = 0
  force_delete      = true
  security_groups   = [dependency.sg.outputs.ids["${local.prefix}-well-known"]]

  # backup
  backup_model     = "physical"
  backup_time      = "02:00-06:00"
  retention_period = 7

  #
  accounts = {
  }

  databases = {
    default = {
      db_name            = local.db_name
      character_set_name = "utf8"
    }
  }

  tags = local.tags
}
