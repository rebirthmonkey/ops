locals {
  app2_sub_domain = "${local.prefix}-app2-${var.short_region}"
  app2_domain     = "${local.app2_sub_domain}.${local.public_domain}"

  app2_vars = {
    PRIVATE_DOMAIN   = local.private_domain
    DB_PASSWORD = var.db_password
#     TLS_LOAD_BALANCER_ID =  module.app2_tls_clb.clb_id
    LOAD_BALANCER_ID = module.app2_clb.clb_id
    REPOSITORY_ID    = "${var.tcr_name}.tencentcloudcr.com"
    NAMESPACE        = "images"
  }
}


module "app2_clb" {
  source = "../../modules/clb"

  project_id                   = var.project_id
  clb_name                     = "${local.prefix}-app2"
  clb_tags                     = local.tags

  network_type                 = "OPEN" // 'OPEN' and 'INTERNAL'
  vpc_id                       = module.network.vpc_id
#   security_groups              = [module.security_group.id]
  security_groups              = [local.default_sg_id]

  create_clb_log               = false
  dynamic_vip                  = true
  address_ip_version           = "ipv4" // pv4, ipv6 and IPv6FullChain.
  internet_bandwidth_max_out   = 100 // [1, 2048]
  internet_charge_type         = "TRAFFIC_POSTPAID_BY_HOUR" //  TRAFFIC_POSTPAID_BY_HOUR, BANDWIDTH_POSTPAID_BY_HOUR and BANDWIDTH_PACKAGE.
  load_balancer_pass_to_target = true
  master_zone_id               = local.clb_master_zone_id
  slave_zone_id                = local.clb_slave_zone_id
  tags                         = local.tags
  create_listener              = false
}


# module "ssl" {
#   source     = "../../modules/ssl_free"
#   certificates = {
#     app2 = {
#       alias = local.app2_sub_domain
#       domain = local.app2_domain
#     }
#   }
# }