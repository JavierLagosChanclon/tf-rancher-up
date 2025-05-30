locals {
  ssh_username = var.instance_ami != null ? var.ssh_username : var.os_type == "sles" ? "ec2-user" : "ubuntu"
}

module "master_nodes" {
  source = "../../../../modules/infra/aws/ec2"

  prefix                  = "${var.prefix}-m"
  instance_count          = var.master_nodes_count
  instance_type           = var.master_nodes_instance_type
  instance_disk_size      = var.master_nodes_instance_disk_size
  instance_ami            = var.instance_ami
  os_type                 = var.os_type
  sles_version            = var.sles_version
  ubuntu_version          = var.ubuntu_version
  create_ssh_key_pair     = var.create_ssh_key_pair
  ssh_key_pair_name       = var.ssh_key_pair_name
  ssh_key_pair_path       = var.ssh_key_pair_path
  ssh_key                 = var.ssh_key
  ssh_username            = local.ssh_username
  aws_region              = var.aws_region
  create_security_group   = var.create_security_group
  instance_security_group = var.instance_security_group
  subnet_id               = var.subnet_id
  bastion_host            = var.bastion_host
  aws_access_key          = var.aws_access_key
  aws_secret_key          = var.aws_secret_key
  user_data = templatefile("${path.module}/user_data.tmpl",
    {
      install_docker = var.install_docker
      username       = local.ssh_username
      docker_version = var.docker_version
    }
  )
  iam_instance_profile = var.master_nodes_iam_instance_profile != null ? var.master_nodes_iam_instance_profile : null
  tags                 = var.tags
}

module "worker_nodes" {
  source = "../../../../modules/infra/aws/ec2"

  prefix                  = "${var.prefix}-w"
  instance_count          = var.worker_nodes_count
  instance_type           = var.worker_nodes_instance_type
  instance_disk_size      = var.worker_nodes_instance_disk_size
  instance_ami            = var.instance_ami
  os_type                 = var.os_type
  sles_version            = var.sles_version
  ubuntu_version          = var.ubuntu_version
  create_ssh_key_pair     = var.create_ssh_key_pair
  ssh_key_pair_name       = var.ssh_key_pair_name
  ssh_key_pair_path       = var.ssh_key_pair_path
  ssh_key                 = var.ssh_key
  ssh_username            = local.ssh_username
  aws_region              = var.aws_region
  create_security_group   = var.create_security_group
  instance_security_group = var.instance_security_group
  subnet_id               = var.subnet_id
  bastion_host            = var.bastion_host
  aws_access_key          = var.aws_access_key
  aws_secret_key          = var.aws_secret_key
  user_data = templatefile("${path.module}/user_data.tmpl",
    {
      install_docker = var.install_docker
      username       = local.ssh_username
      docker_version = var.docker_version
    }
  )
  iam_instance_profile = var.worker_nodes_iam_instance_profile != null ? var.worker_nodes_iam_instance_profile : null
  tags                 = var.tags
}

locals {
  master_nodes = [for instance_ips in module.master_nodes.instance_ips :
    {
      public_ip         = instance_ips.public_ip,
      private_ip        = instance_ips.private_ip,
      roles             = ["etcd", "controlplane"],
      ssh_key_path      = var.ssh_key_pair_path,
      ssh_key           = var.ssh_key
      node_username     = module.master_nodes.node_username,
      hostname_override = instance_ips.private_dns
    }
  ]
  worker_nodes = [for instance_ips in module.worker_nodes.instance_ips :
    {
      public_ip         = instance_ips.public_ip,
      private_ip        = instance_ips.private_ip,
      roles             = ["worker"],
      ssh_key_path      = var.ssh_key_pair_path,
      ssh_key           = var.ssh_key
      node_username     = module.worker_nodes.node_username
      hostname_override = instance_ips.private_dns
    }
  ]
}

module "rke" {
  source                 = "../../../../modules/distribution/rke"
  prefix                 = var.prefix
  node_username          = local.ssh_username
  create_kubeconfig_file = var.create_kubeconfig_file
  kube_config_path       = var.kube_config_path
  kube_config_filename   = var.kube_config_filename
  kubernetes_version     = var.kubernetes_version
  bastion_host           = var.bastion_host
  cloud_provider         = var.cloud_provider

  rancher_nodes = concat(local.master_nodes, local.worker_nodes)
}