module "clss" {
  source  = "../../modules/clss"

  logsets = {
    "standard" = {
      logset_name = local.prefix
      topics      = {
        "tke_event" = {
          topic_name = "${local.prefix}-tke-event"
          tags       = local.tags
        }

        "tke_cluster_audit" = {
          topic_name = "${local.prefix}-tke-cluster-audit"
          tags       = local.tags
        }

        #        "eo-frontend" = {
        #          topic_name = "${local.prefix}-eo-frontend"
        #          tags       = local.tags
        #        }
        #        "eo-app1" = {
        #          topic_name = "${local.prefix}-eo-app1"
        #          tags       = local.tags
        #        }

        "clb-frontend" = {
          topic_name = "${local.prefix}-clb-frontend"
          tags       = local.tags
        }

        "clb-app1" = {
          topic_name = "${local.prefix}-clb-app1"
          tags       = local.tags
        }
      }
    }
  }
}