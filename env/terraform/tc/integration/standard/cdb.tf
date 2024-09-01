locals {
  mysql_password      = var.db_password
  availability_zone   = var.cdb_availability_zone # "ap-nanjing-1"
  first_slave_zone    = var.cdb_first_slave_zone #"ap-nanjing-3"
  mysql_intranet_port = 3306
#   db_name             = "oo"  # db name should be lowercase
  db_name             = var.db_name  # db name should be lowercase
}

module "cdbs" {
  source            = "../../modules/mysql"
  instance_name     = local.prefix
  project_id        = var.project_id
#   security_groups   = [module.security_group.id]
  security_groups   = [local.default_sg_id]
  root_password     = local.mysql_password

  vpc_id            = module.network.vpc_id
  subnet_id         = module.db_network.subnet_id[0]

  engine_version    = "8.0"
  device_type       = "UNIVERSAL"
  mem_size          = 8000
  cpu               = 4
  volume_size       = 25
  parameters        = {}
  availability_zone = local.availability_zone
  first_slave_zone  = local.first_slave_zone
  slave_sync_mode   = 0 # 0 - Async replication; 1 - Semisync replication; 2 - Strongsync replication.
  slave_deploy_mode = 1 # 0 - Single availability zone; 1 - Multiple availability zones.
  internet_service  = 0
  intranet_port     = local.mysql_intranet_port
  charge_type       = "POSTPAID"
  prepaid_period    = null
  auto_renew_flag   = 0
  force_delete      = true

  # backup
  backup_model     = "physical"
  backup_time      = "02:00-06:00"
  retention_period = 7

  # config
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