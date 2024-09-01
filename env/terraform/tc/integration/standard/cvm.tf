locals {
#   cvm_password     = "PassW0rd!"    # 测试机和伸缩组云主机登录密码
  cvm_password     = var.cvm_password
  instance_type    = "S5.MEDIUM2"
  os_name          = "CentOS 7.9 64"
  system_disk_size = 50
  user_data_raw    = file("../../integration/standard/init.sh")
}

module "cvm" {
  source            = "../../modules/cvm"
  availability_zone = local.availability_zones[0]
  project_id        = var.project_id
  tags              = local.tags

#   security_group_ids= [module.security_group.id]
  security_group_ids= [local.default_sg_id]
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.subnet_id[0]

  instance_name     = "${local.prefix}-man"
  instance_type     = local.instance_type
  os_name           = local.os_name
  system_disk_size  = local.system_disk_size
  allocate_public_ip= false
  user_data_raw     = local.user_data_raw
  password          = local.cvm_password
}