locals {
  prefix       = "oo-${random_string.prefix.result}" # or var.prefix    # 为避免资源重名，请修改该前缀

#   project_id   = var.project_id # 1200385           # 项目 id， 与主账号和项目有关，例如大客户售后账号下国际组项目 id 为 1200385
#   region       = var.region # "ap-nanjing"
#   short_region = var.short_region

  tags = {
    created = "Terraform"
    prefix  = local.prefix
  }
}
