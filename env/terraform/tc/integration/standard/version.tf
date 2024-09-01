terraform {
  required_version = ">= 0.12"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">1.18.1"
    }
  }
}

provider "tencentcloud" {
  region = var.region
  domain = var.tencentcloud_api_domain # "internal.tencentcloudapi.com"
}