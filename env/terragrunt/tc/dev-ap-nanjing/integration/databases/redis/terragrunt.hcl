terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//rediss?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix

  redis_password           = local.parent_vars.locals.db_password
  redis_availability_zone  = local.env_vars.network.availability_zones[0] # "ap-nanjing-1"
  redis_replica_zone_names = [local.env_vars.network.availability_zones[2]] # ["ap-nanjing-3"]
  redis_type_id            = 16
  redis_shard_num          = 3
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

inputs = {
  vpc_id            = dependency.vpc.outputs.vpc_id
  subnet_id         = dependency.subnet.outputs.subnet_id[0]

  instances = {
    default = {
      name : "${local.prefix}"
      force_delete : true
      password : local.redis_password
      mem_size : 4096
      availability_zone : local.redis_availability_zone
      replica_zone_names : local.redis_replica_zone_names
      //Description of type_id:
      //Type of the redis instance, available values include:
      //2: Redis 2.8 Memory Edition (Standard Architecture).
      //3: CKV 3.2 Memory Edition (Standard Architecture).
      //4: CKV 3.2 Memory Edition (Cluster Architecture).
      //6: Redis 4.0 Memory Edition (Standard Architecture).
      //7: Redis 4.0 Memory Edition (Cluster Architecture).
      //8: Redis 5.0 Memory Edition (Standard Architecture).
      //9: Redis 5.0 Memory Edition (Cluster Architecture).
      //15: Redis 6.2 Memory Edition (Standard Architecture).
      //16: Redis 6.2 Memory Edition (Cluster Architecture).
      //Please check the document https://www.tencentcloud.com/zh/document/product/239/32069 for up-to-date type ids.
      type_id : local.redis_type_id
      redis_shard_num : local.redis_shard_num
    }
  }
}
