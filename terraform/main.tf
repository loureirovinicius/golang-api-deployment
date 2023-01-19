data "google_client_config" "default" {}

resource "google_project_service" "project" {
  project = data.google_client_config.default.project
  for_each = var.apis
  service = each.value

  timeouts {
    create = "30m"
  }

  disable_dependent_services = true
  disable_on_destroy = true
}

resource "time_sleep" "wait_apis_activation" {
  depends_on = [
    google_project_service.project
  ]
  create_duration = "30s"
}

resource "google_compute_global_address" "ingress_static_ip" {
  name         = var.static_ip_name
  address_type = "EXTERNAL"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 6.0"

  project_id   = data.google_client_config.default.project
  network_name = var.network_name
  routing_mode = "GLOBAL"

  depends_on = [
    time_sleep.wait_apis_activation
  ]

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.subnet_ip
      subnet_region = var.gcp_configs.region
    }
  ]

  secondary_ranges = {
    (var.subnet_name) = [
      {
        range_name    = var.pods_cidr_range.name
        ip_cidr_range = var.pods_cidr_range.ip_cidr_range
      },
      {
        range_name    = var.services_cidr_range.name
        ip_cidr_range = var.services_cidr_range.ip_cidr_range
      }
    ]
  }

  routes = var.routes
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = data.google_client_config.default.project
  name                       = var.cluster_name
  region                     = var.gcp_configs.region
  zones                      = var.zones
  network                    = module.vpc.network_name
  subnetwork                 = var.subnet_name
  ip_range_pods              = var.pods_cidr_range.name
  ip_range_services          = var.services_cidr_range.name
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  
  depends_on = [
    time_sleep.wait_apis_activation,
    module.vpc
  ]

  node_pools = [ 
    {
      name               = var.node_pool_name
      machine_type       = var.machine_type
      node_locations     = join(", ", var.zones)
      min_count          = var.min_nodes
      max_count          = var.max_nodes
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = var.disk_size_gb
      disk_type          = var.disk_type
      image_type         = var.image_type
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = var.gcp_configs.service_account_email
      preemptible        = false
    } 
  ]
}