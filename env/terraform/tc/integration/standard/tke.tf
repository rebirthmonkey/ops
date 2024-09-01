locals {
  tke_system_disk_type    = "CLOUD_BSSD"
  tke_create_cam_strategy = false

  docker_graph_path = "/var/lib/docker"

  tke               = {
    node_pools = {
      default = {
        name             = "default"
        node_os          = "ubuntu20.04x86_64"
        instance_type    = var.tke_instance_type # "S6.LARGE8" "SA5.LARGE8"
        system_disk_type = local.tke_system_disk_type
        max_size         = 3
        min_size         = 0
        desired_capacity = 2
        labels           = {
          node-group : "default"
        }
        data_disks = [
          {
            disk_type : "CLOUD_SSD"
            disk_size : 100
            file_system : "ext4"
          }
        ]
      }
    }
  }
}

module "tke" {
  source                        = "../../modules/tke"
  create_cam_strategy           = local.tke_create_cam_strategy
  cluster_name                  = "${local.prefix}-1"
  cluster_version               = "1.28.3"
  cluster_level                 = "L5"
  container_runtime             = "containerd"
  network_type                  = "VPC-CNI" // Cluster network type, GR or VPC-CNI. Default is GR
  vpc_id                        = module.network.vpc_id
  intranet_subnet_id            = module.network.az_to_subnets[var.tke_endpoint_az][0]
  available_zone                = var.tke_endpoint_az
#   node_security_group_id        = module.security_group.id
  node_security_group_id        = local.default_sg_id
#   cluster_security_group_id     = module.security_group.id
  cluster_security_group_id     = local.default_sg_id
  eni_subnet_ids                = module.tke_pod_network.subnet_id
  cluster_service_cidr          = "192.168.128.0/17"
  cluster_max_service_num       = 32768
  cluster_max_pod_num           = 64
  cluster_cidr                  = ""
  deletion_protection           = false

  # endpoints
  create_endpoint_with_cluster     = false
  cluster_public_access            = true
  cluster_private_access           = true
  cluster_private_access_subnet_id = module.network.az_to_subnets[var.tke_endpoint_az][0]

  enable_log_agent                 = var.tke_enable_logging
  enable_event_persistence         = var.tke_enable_logging
  enable_cluster_audit_log         = var.tke_enable_logging
  event_log_set_id                 = module.clss.logset_ids["standard"]
  cluster_audit_log_set_id         = module.clss.logset_ids["standard"]
  event_log_topic_id               = module.clss.topic_ids["standard_tke_event"]
  cluster_audit_log_topic_id       = module.clss.topic_ids["standard_tke_cluster_audit"]


  tags = local.tags

  cluster_addons = {
    tcr = {
      installed = true
      version   = "1.0.1"
      values    = [
        # imagePullSecretsCrs is an array which can configure image pull
        "global.imagePullSecretsCrs[0].name=${module.tcr.tcr_id}-vpc",
        #specify a unique name, invalid format as: `${tcrId}-vpc`
        "global.imagePullSecretsCrs[0].namespaces=*",
        #input the specified namespaces of the cluster, or input `*` for all.
        "global.imagePullSecretsCrs[0].serviceAccounts=*",
        #input the specified service account of the cluster, or input `*` for all.
        "global.imagePullSecretsCrs[0].type=docker", #only support docker now
        "global.imagePullSecretsCrs[0].dockerUsername=${module.tcr.user_name}",
        #input the access username, or you can create it from data source `tencentcloud_tcr_tokens`
        "global.imagePullSecretsCrs[0].dockerPassword=${module.tcr.token}",
        #input the access token, or you can create it from data source `tencentcloud_tcr_tokens`
        "global.imagePullSecretsCrs[0].dockerServer=${module.tcr.tcr_name}-vpc.tencentcloudcr.com",
        #invalid format as: `${tcr_name}-vpc.tencentcloudcr.com`
        "global.imagePullSecretsCrs[1].name=${module.tcr.tcr_id}-public",
        #specify a unique name, invalid format as: `${tcr_id}-public`
        "global.imagePullSecretsCrs[1].namespaces=*",
        "global.imagePullSecretsCrs[1].serviceAccounts=*",
        "global.imagePullSecretsCrs[1].type=docker",
        "global.imagePullSecretsCrs[1].dockerUsername=${module.tcr.user_name}", #refer to previous description
        "global.imagePullSecretsCrs[1].dockerPassword=${module.tcr.token}", #refer to previous description
        "global.imagePullSecretsCrs[1].dockerServer=${module.tcr.tcr_name}.tencentcloudcr.com",
        #invalid format as: `${tcr_name}.tencentcloudcr.com`
        "global.cluster.region=${var.short_region}",
        "global.cluster.longregion=${var.region}",
        # Specify global hosts(optional), the numbers of hosts must be matched with the numbers of imagePullSecretsCrs
        "global.hosts[0].domain=${module.tcr.tcr_name}-vpc.tencentcloudcr.com",
        #Corresponds to the dockerServer in the imagePullSecretsCrs above
        "global.hosts[0].ip=${lookup(module.tcr.access_ips, module.network.vpc_id, "100.100.100.100")}",
        #input InternalEndpoint of tcr instance, you can get it from data source `tencentcloud_tcr_instances`
        "global.hosts[0].disabled=false", #disabled this host config or not
        "global.hosts[1].domain=${module.tcr.tcr_name}.tencentcloudcr.com",
        "global.hosts[1].ip=${lookup(module.tcr.access_ips, module.network.vpc_id, "100.100.100.100")}",
        "global.hosts[1].disabled=false",
      ]
    }
  }
  # workers
  create_workers_with_cluster = false

  self_managed_node_groups = {
    for k, node_group in local.tke.node_pools : k => {
      name                     = try(node_group.name, k)
      max_size                 = node_group.max_size
      min_size                 = node_group.min_size
      subnet_ids               = module.tke_node_network.subnet_id
      retry_policy             = "IMMEDIATE_RETRY"
      desired_capacity         = node_group.desired_capacity
      enable_auto_scale        = true
      multi_zone_subnet_policy = "EQUALITY"
      node_os                  = node_group.node_os

      docker_graph_path = local.docker_graph_path
      data_disk         = []

      auto_scaling_config = [
        {
          instance_type              = node_group.instance_type
          system_disk_type           = node_group.system_disk_type
          system_disk_size           = 50
#           orderly_security_group_ids = [module.security_group.id]
          orderly_security_group_ids = [local.default_sg_id]
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
      tags = local.tags
      labels      = try(node_group.labels, {})
      taints      = try(node_group.taints, [])
      node_config = [
        {
          extra_args = []
        }
      ]
    }
  }
}
