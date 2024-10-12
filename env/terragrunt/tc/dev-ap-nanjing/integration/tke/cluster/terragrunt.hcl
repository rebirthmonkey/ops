terraform {
  source = "git::https://github.com/rebirthmonkey/terraform.git//tke?ref=main"
}

locals {
  #  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  parent_vars = read_terragrunt_config(find_in_parent_folders())
  env_vars    = local.parent_vars.locals.env_vars
  global_vars = local.parent_vars.locals.global
  tags        = merge(local.global_vars.tags, {})
  prefix      = local.parent_vars.locals.prefix
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path  = "../../network/vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

dependency "node-subnet" {
  config_path  = "../../network/tke_node_subnet"
  mock_outputs = {
    subnet_id = []
  }
}

dependency "pod-subnet" {
  config_path  = "../../network/tke_pod_subnet"
  mock_outputs = {
    subnet_id = []
  }
}

dependency "sg" {
  config_path  = "../../security-group/all"
  mock_outputs = {
    ids = {}
  }
}


inputs = {
  create_cam_strategy = false
  create_cluster = true

  # cluster
  cluster_name              = "test-tke-cluster"
  cluster_version           = "1.28.3"
  cluster_level             = "L5"
  container_runtime         = "containerd"
  network_type              = "VPC-CNI" // Cluster network type, GR or VPC-CNI. Default is GR
  vpc_id                    = dependency.vpc.outputs.vpc_id
  node_security_group_id    = [try(dependency.sg.outputs.ids["${local.prefix}-well-known"], "")]
  eni_subnet_ids            = dependency.pod-subnet.outputs.subnet_id
  cluster_service_cidr      = "192.168.128.0/17"
  cluster_max_service_num   = 32768 # this number must equal to the ip number of cluster_service_cidr
  cluster_max_pod_num       = 64
  cluster_cidr              = ""
  deletion_protection       = false

  # workers
  create_workers_with_cluster = false
  self_managed_node_groups = {
    node_group_1 = {
      name                     = "ng-1"
      deletion_protection = false
      max_size                 = 5
      min_size                 = 1
      subnet_ids               = dependency.node-subnet.outputs.subnet_id
      retry_policy             = "IMMEDIATE_RETRY"
      desired_capacity         = 3
      enable_auto_scale        = true
      multi_zone_subnet_policy = "EQUALITY"
      node_os                  = "ubuntu20.04x86_64"

      docker_graph_path = "/var/lib/docker"
      data_disk = [
        {
          disk_type = "CLOUD_SSD"
          disk_size = 100 # at least to configurate a disk size for data disk
          delete_with_instance = true
          auto_format_and_mount = true
          file_system = "ext4"
          mount_target = "/var/lib/docker"
        }
      ]

      auto_scaling_config = [
        {
          instance_type              = "S5.LARGE8"
          system_disk_type           = "CLOUD_SSD"
          system_disk_size           = 50
          orderly_security_group_ids = [try(dependency.sg.outputs.ids["${local.prefix}-well-known"], "")]
          key_ids                    = null
          internet_charge_type       = null
          internet_max_bandwidth_out = null
          public_ip_assigned         = false
          enhanced_security_service  = true
          enhanced_monitor_service   = true
          host_name                  = "tke-node"
          host_name_style            = "ORIGINAL"
        }
      ]

      labels      = {}
      taints      = []
      node_config = [
        {
          extra_args = concat(["root-dir=/var/lib/kubelet"],
            []
          )
        }
      ]
    }
  }

  # endpoints
  create_endpoint_with_cluster     = false
  cluster_public_access             = true
  cluster_security_group_id = try(dependency.sg.outputs.ids["${local.prefix}-well-known"], "")
  cluster_private_access                = false
  cluster_private_access_subnet_id      = ""

  # tags
  tags = {
    create: "terraform"
  }
}
