locals {
  # app1
  app1_server_port   = 8888
  app1_sub_domain    = "${local.prefix}-app1-${var.region}"
  app1_domain        = "${local.app1_sub_domain}.${local.public_domain}"
  app1_app_vars      = {
    COS_BUCKET     = "ruan-1251956900"
    COS_REGION     = "ap-guangzhou"
    COS_PATH       = "/app1"
    PRIVATE_DOMAIN = local.private_domain
    DB_PASSWORD    = var.db_password
  }

  # as_configuration
  app1_as_cvm_password               = var.cvm_password    # 测试机和伸缩组云主机登录密码
  app1_as_instance_type              = "S5.MEDIUM2"
  app1_as_os_name                    = "CentOS 7.9 64"
  app1_as_system_disk_size           = 50
  app1_as_internet_max_bandwidth_out = 100
  app1_as_user_data_raw              = templatefile("../../integration/standard/app1.sh.tftpl", local.app1_app_vars)

  # as_group
  app1_as_max_size                   = 3                # 伸缩组最大 CVM 数，当前 case 不用修改
  app1_as_min_size                   = 1                # 伸缩组最小 CVM 数，当前 case 不用修改
  app1_as_desired_capacity           = 2                # 伸缩组当前指定 CVM 数，当前 case 不用修改

  # as_policies
  app1_as_create_policies            = false
}

module "app1_clb" {
  source                       = "../../modules/clb"
  project_id                   = local.project_id
  clb_name                     = "${local.prefix}-app1"
  clb_tags                     = local.tags
  tags                         = local.tags

  network_type                 = "OPEN" // 'OPEN' and 'INTERNAL'
  vpc_id                       = module.network.vpc_id
  security_groups              = [module.security_group.id]

  create_clb_log               = false
  dynamic_vip                  = true
  address_ip_version           = "ipv4" // pv4, ipv6 and IPv6FullChain.
  internet_bandwidth_max_out   = 100 // [1, 2048]

  internet_charge_type         = "TRAFFIC_POSTPAID_BY_HOUR"  //  TRAFFIC_POSTPAID_BY_HOUR, BANDWIDTH_POSTPAID_BY_HOUR and BANDWIDTH_PACKAGE.
  load_balancer_pass_to_target = true
  master_zone_id               = local.clb_master_zone_id
  slave_zone_id                = local.clb_slave_zone_id
  create_listener              = true
  clb_listeners                = [
    {
      listener_name = "http_listener"
      protocol      = "HTTP"
      port          = 80
    },
  ]
  create_listener_rules = true
  clb_listener_rules    = [
    {
      listener_index = 0
      domain         = local.app1_domain
      url            = "/"
    },
  ]
}

module "app1_as" {
  depends_on = [module.app1_clb, module.redis]
  source     = "../../modules/as"

  # as instance
  project_id         = local.project_id
  tags               = local.tags

  # as_configuration
  configuration_name = "${local.prefix}-app1"
  instance_name      = "${local.prefix}-app1"
  instance_types     = [local.app1_as_instance_type]
  os_name            = local.app1_as_os_name
  system_disk_size   = local.app1_as_system_disk_size
  password           = local.app1_as_cvm_password
  security_group_ids = [module.security_group.id]
  user_data_raw      = local.app1_as_user_data_raw

  # as_group
  scaling_group_name  = "${local.prefix}-app1"
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.app1_network.subnet_id
  as_max_size         = local.app1_as_max_size
  as_min_size         = local.app1_as_min_size
  as_desired_capacity = local.app1_as_desired_capacity

  # as_policies
  as_policies = {
    increment = {
      create              = local.app1_as_create_policies
      policy_name         = "scale_up"
      adjustment_type     = "CHANGE_IN_CAPACITY"
      adjustment_value    = 1
      comparison_operator = "GREATER_THAN"
      metric_name         = "LAN_TRAFFIC_OUT"
      threshold           = 1
      period              = 60
      continuous_time     = 1
      statistic           = "MAXIMUM"
      cooldown            = 120
    }
    decrement = {
      create              = local.app1_as_create_policies
      policy_name         = "scale_down"
      adjustment_type     = "CHANGE_IN_CAPACITY"
      adjustment_value    = -1
      comparison_operator = "LESS_THAN"
      metric_name         = "LAN_TRAFFIC_OUT"
      threshold           = 1
      period              = 60
      continuous_time     = 1
      statistic           = "MAXIMUM"
      cooldown            = 120
    }
  }

  # load balancer
  forward_balancers = [
    {
      load_balancer_id  = module.app1_clb.clb_id
      listener_id       = module.app1_clb.clb_listener_id[0]
      rule_id           = module.app1_clb.clb_listener_rule_id[0]
      target_attributes = [
        {
          target_port = local.app1_server_port
        }
      ]
    }
  ]
}
