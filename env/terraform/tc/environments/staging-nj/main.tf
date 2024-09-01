module "standard" {
  source = "../../integration/standard"

  # general
  region                  = "ap-nanjing"
  short_region            = "nj"
  availability_zones      = ["ap-nanjing-1", "ap-nanjing-2", "ap-nanjing-3"]
  tencentcloud_api_domain = "internal.tencentcloudapi.com"
#   project_id = 1321390 # intl center
  project_id              = 1200385 # china-tam center


  # foundation
  vpc_cidr                = "10.0.0.0/16"
  man_cidrs               = ["10.0.0.0/24", "10.0.1.0/24","10.0.2.0/24"]
  frontend_cidrs          = ["10.0.4.0/24", "10.0.5.0/24","10.0.6.0/24"]
  app1_cidrs              = ["10.0.8.0/24", "10.0.9.0/24","10.0.10.0/24"]
  db_cidrs                = ["10.0.12.0/24", "10.0.13.0/24","10.0.14.0/24"]

  # dns
  public_domain           = "tmigrate.com"
  dns_record_line         = "默认"

  # cvm
  cvm_password            = "P@ssw0rd"

  # cdb
  cdb_availability_zone   = "ap-nanjing-1"
  cdb_first_slave_zone    = "ap-nanjing-3"
  db_name                 = "oo"
  db_password             = "P@ssw0rd"

  # redis
  redis_availability_zone = "ap-nanjing-1"
  redis_replica_zone_names= ["ap-nanjing-3"]

  # tcr
  tcr_availability_zone   = "ap-nanjing-3"
  tcr_name                = "oo-registry"

  # tke
  node_cidrs              = ["10.0.64.0/24","10.0.65.0/24","10.0.66.0/24"]
  node_azs                = ["ap-nanjing-1", "ap-nanjing-2", "ap-nanjing-3"]
  pod_cidrs               = ["10.0.128.0/24","10.0.129.0/24","10.0.130.0/24" ]
  pod_azs                 = ["ap-nanjing-1", "ap-nanjing-2", "ap-nanjing-3"]
  tke_endpoint_az         = "ap-nanjing-3"
  tke_instance_type       = "S6.LARGE8"


  # frontend
  clb_master_zone_id      = "ap-nanjing-1"
  clb_slave_zone_id       = "ap-nanjing-3"
}