variable "do_token" {
  type        = string
  description = "DigitalOcean Authentication Token"
  default     = null
  sensitive   = true
}

variable "droplet_count" {
  type        = number
  description = "Number of droplets to create"
  default     = 3
  nullable    = false
}

variable "droplet_size" {
  type        = string
  description = "Size used for all droplets"
  default     = "s-2vcpu-4gb"
  nullable    = false
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "rancher-terraform"
}

variable "tag_begin" {
  type        = number
  description = "Tag from this number when module is called more than once"
  default     = 1
}

variable "create_ssh_key_pair" {
  type        = bool
  description = "Specify if a new SSH key pair needs to be created for the instances"
  default     = true
  nullable    = false
}

variable "ssh_key_pair_name" {
  type        = string
  description = "Specify the SSH key name to use (that's already present in DigitalOcean)"
  default     = null
}

variable "ssh_key_pair_path" {
  type        = string
  description = "Path to the SSH private key used as the key pair (that's already present in DigitalOcean)"
  default     = null
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to write the generated SSH private key"
  default     = null
}

variable "region" {
  type        = string
  description = "Region that droplets will be deployed to"
  default     = "sfo3"

  validation {
    condition = contains([
      "nyc1",
      "nyc3",
      "ams3",
      "sfo2",
      "sfo3",
      "sgp1",
      "lon1",
      "fra1",
      "tor1",
      "blr1",
      "syd1",
    ], var.region)
    error_message = "Invalid Region specified!"
  }
}

variable "ssh_username" {
  description = "The user account used to connect to droplets via ssh"
  type        = string
  default     = "root"
  nullable    = false
}

variable "waiting_time" {
  description = "Waiting time (in seconds)"
  type        = number
  default     = 60
}

variable "kube_config_path" {
  description = "The path to write the kubeconfig for the RKE cluster"
  type        = string
  default     = null
}

variable "kube_config_filename" {
  description = "Filename to write the kube config"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the RKE cluster"
  default     = null
}

variable "rancher_bootstrap_password" {
  description = "Password to use when bootstrapping Rancher (min 12 characters)"
  default     = "initial-bootstrap-password"
  type        = string

  validation {
    condition     = length(var.rancher_bootstrap_password) >= 12
    error_message = "The password provided for Rancher (rancher_bootstrap_password) must be at least 12 characters"
  }
}

variable "rancher_password" {
  description = "Password for the Rancher admin account (min 12 characters)"
  default     = null
  type        = string

  validation {
    condition     = length(var.rancher_password) >= 12
    error_message = "The password provided for Rancher (rancher_password) must be at least 12 characters"
  }
}

variable "rancher_version" {
  description = "Rancher version to install"
  default     = null
  type        = string
}

variable "rancher_helm_repository" {
  description = "Helm repository for Rancher chart"
  default     = null
  type        = string
}

variable "rancher_helm_repository_username" {
  description = "Private Rancher helm repository username"
  default     = null
  type        = string
}

variable "rancher_helm_repository_password" {
  description = "Private Rancher helm repository password"
  default     = null
  type        = string
}

variable "wait" {
  description = "An optional wait before installing the Rancher helm chart"
  default     = "20s"
}

variable "create_k8s_api_loadbalancer" {
  type        = bool
  description = "Specify if a loadbalancer for port 6443 needs to be created for the instances"
  default     = false
  nullable    = false
}

variable "create_https_loadbalancer" {
  type        = bool
  description = "Specify if a loadbalancer for port 443 needs to be created for the instances"
  default     = false
  nullable    = false
}

variable "droplet_image" {
  type        = string
  description = "name of the OpenSUSE custom image uploaded to DigitalOcean account"
  default     = "openSUSE-Leap-15.6"
  nullable    = false
}

variable "os_type" {
  description = "Operating system type (opensuse or ubuntu)"
  type        = string
  default     = "opensuse"

  validation {
    condition     = contains(["opensuse", "ubuntu"], var.os_type)
    error_message = "The operating system type must be 'opensuse' or 'ubuntu'."
  }
}
