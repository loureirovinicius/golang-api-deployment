variable "gcp_configs" {
  type = object({
    project            = string,
    region             = string,
    zone               = string,
    service_account_email = string,
  })
  description = "Required informations to use the provider."
}

variable "apis" {
  type = set(string)
  default = ["container.googleapis.com", "compute.googleapis.com"]
  description = "Required APIs to be enabled in order to use some resources."
}

variable "network_name" {
  type = string
  default = "golang-crud-vpc"
  description = "VPC name"
}

variable "subnet_name" {
  type = string
  default = "subnet-01"
  description = "Subnet name"
}

variable "subnet_ip" {
  type = string
  default = "10.0.0.0/16"
  description = "Subnet's primary ip"
}

variable "pods_cidr_range" {
  type = object({
    name = string,
    ip_cidr_range = string
  })
  default = {
    ip_cidr_range = "192.168.0.0/20"
    name = "pods-range"
  }
  description = "CIDR range used by pods. Must fit into the subnet's primary ip range, otherwise nodes won't scale."
}

variable "services_cidr_range" {
  type = object({
    name = string,
    ip_cidr_range = string
  })
  default = {
    ip_cidr_range = "192.168.64.0/20"
    name = "services-range"
  }
  description = "CIDR range used by services. Must fit into subnet's primary ip range."
}

variable "routes" {
  type = list(map(string))
  default = [ {
    name              = "egress"
    description       = "route through the internet gateway to access internet"
    destination_range = "0.0.0.0/0"
    next_hop_internet = "true"
  } ]
  description = "Routing rules for the VPC."
}

variable "cluster_name" {
  type = string
  default = "gke-golang-api"
  description = "Cluster name"
}

variable "zones" {
  type = set(string)
  default = [ "us-central1-a" ]
  description = "Zones to host the cluster created."
}

variable "node_pool_name" {
  type = string
  default = "managed-node-pool"
  description = "Name of the managed node pool."
}

variable "machine_type" {
  type = string
  default = "e2-micro"
  description = "Machine type to use for nodes. Default value is optimized for low cost."
}

variable "min_nodes" {
  type = number
  default = 2
  description = "Number of initial nodes"
}

variable "max_nodes" {
  type = number
  default = 3
  description = "Max number of nodes"
}

variable "disk_type" {
  type = string
  default = "pd-standard"
  description = "Type of the persistent disk attached to nodes."
}

variable "disk_size_gb" {
  type = number
  default = 10
  description = "Persistent disk size in GB."
}

variable "image_type" {
  type = string
  default = "COS_CONTAINERD"
  description = "The container runtime image to use in nodes"
}

