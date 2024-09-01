locals {
#   # security group
#   well-known-cidrs = [ # 公司出口 IP 段，如果用其他地址访问，请先找到出口 IP ，加入到这个列表里
#     "61.135.194.0/24",
#     "111.206.145.0/24",
#     "59.152.39.0/24",
#     "180.78.55.0/24",
#     "111.206.94.0/24",
#     "111.206.96.0/24",
#   ]
#
#   well-known_ingress = [
#     for cidr in local.well-known-cidrs : format("ACCEPT#%s#ALL#TCP", cidr)
#   ]
#
#   sg_ingress = concat(local.well-known_ingress, [
#     "ACCEPT#0.0.0.0/0#80#TCP",
#     "ACCEPT#${local.vpc_cidr}#ALL#TCP"
#   ])

  # network
  availability_zones  = var.availability_zones # ["ap-nanjing-1", "ap-nanjing-2", "ap-nanjing-3"]   # 资源部署的可用区，与 Region 有关，这里使用的是 ap-nanjing Region
  vpc_cidr            = var.vpc_cidr  # "10.0.0.0/16"
  man_cidrs           = var.man_cidrs # ["10.0.0.0/24", "10.0.1.0/24","10.0.2.0/24" ]
  frontend_cidrs      = var.frontend_cidrs
  app1_cidrs          = var.app1_cidrs
  db_cidrs            = var.db_cidrs
}

resource "random_string" "prefix" {
  length      = 4
  lower       = true
  numeric     = true
  special     = false
  upper       = false
  min_numeric = 1
  min_lower   = 2
}

# module "security_group" {
#   source  = "../../modules/security_group"
#   name    = local.prefix
#   ingress = local.sg_ingress
#   egress  = [
#     "ACCEPT#0.0.0.0/0#ALL#ALL"
#   ]
# }

module "network" {
  source              = "../../modules/vpc"
  availability_zones  = local.availability_zones

  vpc_name            = local.prefix
  vpc_cidr            = local.vpc_cidr
  vpc_is_multicast    = true
  tags                = local.tags

  subnet_name         = "${local.prefix}-man"
  subnet_cidrs        = local.man_cidrs
  subnet_tags         = local.tags

  enable_nat_gateway  = true
  destination_cidrs   = ["0.0.0.0/0"]
  next_type           = ["NAT"]
  next_hub            = ["0"]
}

module "frontend_network" {
  source              = "../../modules/vpc"
  create_vpc          = false
  availability_zones  = var.availability_zones

  vpc_id              = module.network.vpc_id
  tags                = local.tags

  subnet_name         = "${local.prefix}-frontend"
  subnet_cidrs        = local.frontend_cidrs
  subnet_tags         = local.tags
}

module "app1_network" {
  source              = "../../modules/vpc"
  create_vpc          = false
  availability_zones = var.availability_zones

  vpc_id              = module.network.vpc_id
  tags                = local.tags

  subnet_name         = "${local.prefix}-app1"
  subnet_cidrs        = local.app1_cidrs
  subnet_tags         = local.tags
}

module "db_network" {
  source              = "../../modules/vpc"
  create_vpc          = false
  availability_zones = var.availability_zones

  vpc_id              = module.network.vpc_id
  tags                = local.tags

  subnet_name        = "${local.prefix}-db"
  subnet_cidrs       = local.db_cidrs
  subnet_tags        = local.tags
}

module "tke_node_network" {
  source              = "../../modules/vpc"
  create_vpc          = false
  vpc_id              = module.network.vpc_id
  tags                = local.tags

  availability_zones  = var.node_azs
  subnet_name         = "${local.prefix}-tke-node"
  subnet_cidrs        = var.node_cidrs
  subnet_tags         = local.tags
}

module "tke_pod_network" {
  source            = "../../modules/vpc"
  create_vpc        = false
  vpc_id            = module.network.vpc_id
  tags              = local.tags

  availability_zones = var.pod_azs
  subnet_name        = "${local.prefix}-tke-pod"
  subnet_cidrs       = var.pod_cidrs
  subnet_tags        = local.tags
}