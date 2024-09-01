locals {
#   tcr_name = local.prefix
#   tcr_name = var.tcr_name
  tcr_name = var.tcr_name == "" ? "${local.prefix}-tam-lab" : var.tcr_name
  create_instance = var.tcr_create
  existing_tcr_id = concat(data.tencentcloud_tcr_instances.name.instance_list.*.id, [""])[0]
}

data "tencentcloud_tcr_instances" "name" {
  name = local.tcr_name
}

module "tcr" {
  source                = "../../modules/tcr"
  tcr_name              = local.tcr_name
  delete_bucket         = true
  open_public_operation = true
  security_policies     = [
    for cidr in local.well-known-cidrs : {
      cidr_block : cidr
    }
  ]
  instance_type   = "basic"
  vpc_attachments = {
    default = {
      vpc_id                   = module.network.vpc_id
      subnet_id                = module.network.az_to_subnets[var.tcr_availability_zone][0],
      enable_vpc_domain_dns    = true
      enable_public_domain_dns = true
    }
  }
  namespaces = {
    images = {
      name                = "images"
      is_public           = false
      is_auto_scan        = false
      is_prevent_vul      = false
      severity            = null // "medium"  // Block vulnerability level, currently only supports low, medium, high.
      cve_whitelist_items = []
    }
  }

  service_accounts = {
    sa1 = {
      name        = "sa1"
      permissions = [
        {
          namespace = "*"
          actions   = [
            "tcr:PushRepository",
            "tcr:CreateHelmChart",
            "tcr:CreateRepository",
            "tcr:PullRepository",
            "tcr:DescribeHelmCharts"
          ]
        }
      ]
      description = ""
      duration    = 365
      disable     = false
      tags        = local.tags
    }
  }
}