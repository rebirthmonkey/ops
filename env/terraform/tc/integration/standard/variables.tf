# provider
variable "region" {
  type    = string
  default = ""
}

variable "short_region" {
  type    = string
  default = ""
}

variable "tencentcloud_api_domain" {
  type    = string
  default = ""
}

# general
variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "project_id" {
  type    = number
  default = 0
}

# foundation
variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "man_cidrs" {
  type    = list(string)
  default = []
}

variable "frontend_cidrs" {
  type    = list(string)
  default = []
}

variable "app1_cidrs" {
  type    = list(string)
  default = []
}

variable "db_cidrs" {
  type    = list(string)
  default = []
}

# DNS
variable "public_domain" {
  type    = string
  default = ""
}

variable "dns_record_line" {
  type    = string
  default = "默认"
}

# cvm
variable "cvm_password" {
  type    = string
  default = ""
}

# cdb
variable "db_password" {
  type    = string
  default = ""
}

variable "db_name" {
  type    = string
  default = ""
}

variable "cdb_availability_zone" {
  type    = string
  default = ""
}

variable "cdb_first_slave_zone" {
  type    = string
  default = ""
}

# redis
variable "redis_availability_zone" {
  type    = string
  default = ""
}

variable "redis_replica_zone_names" {
  type    = list(string)
  default = []
}

# tcr
variable "tcr_availability_zone" {
  type    = string
  default = ""
}

variable "tcr_name" {
  type    = string
  default = ""
}

variable "tcr_create" {
  type = bool
  default = true
}

# tke
variable "node_cidrs" {
  type    = list(string)
  default = []
}

variable "node_azs" {
  type    = list(string)
  default = []
}

variable "pod_cidrs" {
  type    = list(string)
  default = []
}

variable "pod_azs" {
  type    = list(string)
  default = []
}

variable "tke_endpoint_az" {
  type    = string
  default = ""
}

variable "tke_instance_type" {
  type    = string
  default = ""
}

# variable "tke_system_disk_type" {
#   type    = string
#   default = ""
# }

# variable "tke_create_cam_strategy" {
#   type    = bool
#   default = true
# }

variable "tke_enable_logging" {
  type    = bool
  default = false
}

# frontend
variable "clb_master_zone_id" {
  type    = string
  default = ""
}

variable "clb_slave_zone_id" {
  type    = string
  default = ""
}


