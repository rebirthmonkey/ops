locals {
  tcr_name = "oo-${local.prefix}"

  # app2
  app2_sub_domain = "${local.prefix}-app2-${var.region}"
  app2_domain     = "${local.app2_sub_domain}.${local.public_domain}"

  app2_vars = {
    PRIVATE_DOMAIN   = local.private_domain
    DB_PASSWORD = var.db_password
#     TLS_LOAD_BALANCER_ID =  module.app2_tls_clb.clb_id
#     LOAD_BALANCER_ID = module.app2_clb.clb_id
    REPOSITORY_ID    = "${local.tcr_name}.tencentcloudcr.com"
    NAMESPACE        = "images"
  }
}
