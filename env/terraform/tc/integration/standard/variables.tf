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

# frontend
variable "clb_master_zone_id" {
  type    = string
  default = ""
}

variable "clb_slave_zone_id" {
  type    = string
  default = ""
}


