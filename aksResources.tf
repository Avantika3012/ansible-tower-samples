provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.22.0"
  subscription_id = "1d65b7c6-8441-464d-89ce-165ff0e05be0"
  client_id       = "3f4103d7-e3b7-4c5c-9e02-ef45a842c2a4"
  client_secret   = "FC0WPeAw7SZmkosj9GK9EBFQCsYwN54LHuk/FCbkrbA="
  tenant_id       = "c160a942-c869-429f-8a96-f8c8296d57db"
}
# Create AKS Cluster
resource "tls_private_key" "aks-key" {
  algorithm   = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_kubernetes_cluster" "myAKSCluster" {
  name                = "mycluster"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "tppoCluster-dns"
  kubernetes_version  = "${var.aks_k8s_version}"

  linux_profile {
    admin_username = "babauser"

    ssh_key {
      key_data = "${tls_private_key.aks-key.public_key_openssh}"
    }
  }
  agent_pool_profile {
    name            = "agentpool"
    count           = 1
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "3f4103d7-e3b7-4c5c-9e02-ef45a842c2a4"
    client_secret = "FC0WPeAw7SZmkosj9GK9EBFQCsYwN54LHuk/FCbkrbA="
  }
}
resource "local_file" "kubeconfig" {
  content  = "${azurerm_kubernetes_cluster.myAKSCluster.kube_admin_config_raw}"
  filename = "${path.module}/kubeconfig"
}
variable "nameregion" {
  default = "West US"
}
variable "nameenvironment" {
  default = "Dev"
}
variable "project" {
  default = "TPPO"
}
variable "resource_group_location" {
  default = "West US"
}
variable "resource_group_name" {
  default = "AvniRG"
}
variable "aks_k8s_version" {
  default = "1.12.7"
}


