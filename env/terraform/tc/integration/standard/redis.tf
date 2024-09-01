locals {
  redis_password           = var.db_password
  redis_availability_zone  = var.redis_availability_zone # "ap-nanjing-1"
  redis_replica_zone_names = var.redis_replica_zone_names # ["ap-nanjing-3"]
  redis_type_id            = 16
  redis_shard_num          = 3
}

module "redis" {
  source    = "../../modules/rediss"
  vpc_id    = module.network.vpc_id
  subnet_id = module.db_network.az_to_subnets[local.redis_availability_zone][0]

  instances = {
    default = {
      name : "${local.prefix}"
      force_delete : true
      password : local.redis_password
      mem_size : 4096
      vpc_key : "vpc"
      subnet_name : "subnets"
      availability_zone : local.redis_availability_zone
      replica_zone_names : local.redis_replica_zone_names
      type_id : local.redis_type_id
      redis_shard_num : local.redis_shard_num
    }
  }
}