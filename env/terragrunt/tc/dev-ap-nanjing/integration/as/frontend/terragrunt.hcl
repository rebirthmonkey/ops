terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//as?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix

  server_port = 80

  # as_configuration
  as_cvm_password               = "PassW0rd!"    # 测试机和伸缩组云主机登录密码
  as_instance_type              = "S5.MEDIUM2"
  as_os_name                    = "CentOS 7.9 64"
  as_system_disk_size           = 50
  as_internet_max_bandwidth_out = 100
  as_user_data_raw = templatefile("../../../templates/frontend.sh.tftpl", local.parent_vars.locals.app_vars.frontend)

  # as_group
  as_max_size                   = 3       # 伸缩组最大 CVM 数，当前 case 不用修改
  as_min_size                   = 1       # 伸缩组最小 CVM 数，当前 case 不用修改
  as_desired_capacity           = 2       # 伸缩组当前指定 CVM 数，当前 case 不用修改

  # as_policies
  as_create_policies            = false
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path  = "../../network/vpc"
}

dependency "subnet" {
  config_path  = "../../network/frontend_subnet"
}

dependency "sg" {
  config_path  = "../../security-group/all"
}

dependency "clb" {
  config_path  = "../../clb/frontend"
}

dependency "cdb" {
  config_path  = "../../databases/cdb"
}

dependency "redis" {
  config_path  = "../../databases/redis"
}

inputs = {
  # as_configuration
  configuration_name = "${local.prefix}-frontend"
  tags               = local.tags
  instance_name      = "${local.prefix}-frontend"
  instance_types     = [local.as_instance_type]
  os_name            = local.as_os_name
  system_disk_size   = local.as_system_disk_size
  password           = local.as_cvm_password
  security_group_ids = [dependency.sg.outputs.ids["${local.prefix}-well-known"]]
  user_data_raw      = local.as_user_data_raw

  # as_group
  scaling_group_name  = "${local.prefix}-frontend"
  vpc_id              = dependency.vpc.outputs.vpc_id
  subnet_ids          = dependency.subnet.outputs.subnet_id
  as_max_size         = local.as_max_size
  as_min_size         = local.as_min_size
  as_desired_capacity = local.as_desired_capacity

  # as_policies
  as_policies = {
    increment = {
      create              = local.as_create_policies
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
      create              = local.as_create_policies
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

  #   loadbalancer
  forward_balancers = [
    {
      load_balancer_id  = dependency.clb.outputs.clb_id
      listener_id       = dependency.clb.outputs.clb_listener_id[0]
      rule_id           = dependency.clb.outputs.clb_listener_rule_id[0]
      target_attributes = [
        {
          target_port = local.server_port
        }
      ]
    }
  ]
}
