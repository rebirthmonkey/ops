locals {
  frontend_server_port = 80
  frontend_sub_domain  = "${local.prefix}-frontend-${var.region}"
  frontend_domain      = "${local.frontend_sub_domain}.${local.public_domain}"

  # clb
  clb_master_zone_id = var.clb_master_zone_id # "ap-nanjing-1"
  clb_slave_zone_id  = var.clb_slave_zone_id #"ap-nanjing-3"

  # as_configuration
  frontend_as_cvm_password               = var.cvm_password    # 测试机和伸缩组云主机登录密码
  frontend_as_instance_type              = "S5.MEDIUM2"
  frontend_as_os_name                    = "CentOS 7.9 64"
  frontend_as_system_disk_size           = 50
  frontend_as_internet_max_bandwidth_out = 100
  frontend_as_user_data_raw              = templatefile("../../integration/standard/frontend.sh.tftpl", local.frontend_app_vars)

  # as_group
  frontend_as_max_size                   = 3               # 伸缩组最大 CVM 数，当前 case 不用修改
  frontend_as_min_size                   = 1               # 伸缩组最小 CVM 数，当前 case 不用修改
  frontend_as_desired_capacity           = 2       # 伸缩组当前指定 CVM 数，当前 case 不用修改

  # as_policies
  frontend_as_create_policies            = false

  # app/cos
  frontend_app_vars    = {
    COS_BUCKET  = "ruan-1251956900"
    COS_REGION  = "ap-guangzhou"
    COS_PATH    = "/webapp"
    APP1_DOMAIN = local.app1_domain
    APP2_DOMAIN = local.app2_domain
  }
}

module "frontend_clb" {
  source                       = "../../modules/clb"
  project_id                   = var.project_id
  clb_name                     = "${local.prefix}-frontend"
  clb_tags                     = local.tags

  network_type                 = "OPEN" // 'OPEN' and 'INTERNAL'
  vpc_id                       = module.network.vpc_id
  security_groups              = [module.security_group.id]

  create_clb_log               = false
  dynamic_vip                  = true
  address_ip_version           = "ipv4" // pv4, ipv6 and IPv6FullChain.
  internet_bandwidth_max_out   = 100 // [1, 2048]
  internet_charge_type         = "TRAFFIC_POSTPAID_BY_HOUR" //  TRAFFIC_POSTPAID_BY_HOUR, BANDWIDTH_POSTPAID_BY_HOUR and BANDWIDTH_PACKAGE.
  load_balancer_pass_to_target = true
  master_zone_id               = local.clb_master_zone_id
  slave_zone_id                = local.clb_slave_zone_id
  tags                         = local.tags

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
      domain         = local.frontend_domain
      url            = "/"
    },
  ]
}

module "frontend_as" {
  depends_on = [ module.redis ]
  source     = "../../modules/as"

  # as_configuration
  configuration_name = "${local.prefix}-frontend"
  tags               = local.tags
  project_id         = var.project_id
  instance_name      = "${local.prefix}-frontend"
  instance_types     = [local.app1_as_instance_type]
  os_name            = local.frontend_as_os_name
  system_disk_size   = local.frontend_as_system_disk_size
  password           = local.frontend_as_cvm_password
  security_group_ids = [module.security_group.id]
  user_data_raw      = local.frontend_as_user_data_raw

  # as_group
  scaling_group_name  = "${local.prefix}-frontend"
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.frontend_network.subnet_id
  as_max_size         = local.frontend_as_max_size
  as_min_size         = local.frontend_as_min_size
  as_desired_capacity = local.frontend_as_desired_capacity

  # as_policies
  as_policies = {
    increment = {
      create              = local.frontend_as_create_policies
      policy_name         = "scale_up"
      adjustment_type     = "CHANGE_IN_CAPACITY" // "CHANGE_IN_CAPACITY"
      adjustment_value    = 1 //1
      comparison_operator = "GREATER_THAN" // "GREATER_THAN"
      metric_name         = "LAN_TRAFFIC_OUT" //"CPU_UTILIZATION"
      threshold           = 1 // 80
      period              = 60 // 300
      continuous_time     = 1 // 10
      statistic           = "MAXIMUM" // "AVERAGE"
      cooldown            = 120 // 360
    }
    decrement = {
      create              = local.frontend_as_create_policies
      policy_name         = "scale_down"
      adjustment_type     = "CHANGE_IN_CAPACITY" // "CHANGE_IN_CAPACITY"
      adjustment_value    = -1 //1
      comparison_operator = "LESS_THAN" // "GREATER_THAN"
      metric_name         = "LAN_TRAFFIC_OUT" //"CPU_UTILIZATION"
      threshold           = 1 // 80
      period              = 60 // 300
      continuous_time     = 1 // 10
      statistic           = "MAXIMUM" // "AVERAGE"
      cooldown            = 120 // 360
    }
  }

  # load balancer
  forward_balancers = [
    {
      load_balancer_id  = module.frontend_clb.clb_id
      listener_id       = module.frontend_clb.clb_listener_id[0]
      rule_id           = module.frontend_clb.clb_listener_rule_id[0]
      target_attributes = [
        {
          target_port = local.frontend_server_port
        }
      ]
    }
  ]
}
