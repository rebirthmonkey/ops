locals {
#   private_domain  = "${local.prefix}-tmigrate.com"
  private_domain  = "internal.${var.public_domain}"
  public_domain   = var.public_domain   # tmigrate.com
  dns_record_line = var.dns_record_line # "默认"
}

module "private-dns" {
  source             = "../../modules/private-dns"
  create_private_dns = true
  domain             = local.private_domain

  vpc_sets = [
    {
      region      = var.region
      uniq_vpc_id = module.network.vpc_id
    }
  ]

  dns_forward_status = "ENABLED"
  tags               = local.tags

  records = {
    "cdb" = {
      sub_domain   = "mysql"
      record_type  = "A"
      record_value = module.cdbs.intranet_ip
      ttl          = 600
    }

    "redis" = {
      sub_domain   = "redis"
      record_type  = "A"
      record_value = module.redis.ip.default
      ttl          = 600
    }
  }
}

module "public-dns" {
  source = "../../modules/dns"

  random_domain = false
  domain        = local.public_domain                         # 如果random_domain为false，需要填写域名
  create_domain = false
  remark        = ""

  records = {
    app1 = {
      domain      = local.public_domain
      create      = true
      record_type = "CNAME"
      record_line = local.dns_record_line
      value       = format("%s.", module.app1_clb.clb_domain)
      sub_domain  = local.app1_sub_domain
      mx          = null
      ttl         = 600
      status      = "ENABLE"
    },
#     app2 = {
#       domain      = local.public_domain
#       create      = true
#       record_type = "CNAME"
#       record_line = local.dns_record_line
#       value       = format("%s.", module.app2_clb.clb_domain)
#       sub_domain  = local.app2_sub_domain
#       mx          = null
#       ttl         = 600
#       status      = "ENABLE"
#     },
    frontend = {
      domain      = local.public_domain
      create      = true
      record_type = "CNAME"
      record_line = local.dns_record_line
      value    = format("%s.", module.frontend_clb.clb_domain)
      #      value       = format("%s.", module.tflab-eo.cnames[local.frontend_domain])
      sub_domain  = local.frontend_sub_domain
      mx          = null
      ttl         = 600
      status      = "ENABLE"
    }
  }
}