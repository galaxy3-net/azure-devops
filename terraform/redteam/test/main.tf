# Configure the Microsoft Azure Provider

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "home_ip" {}

variable "team-name-mix" {
  default = "RedTeam"
  #default = "BlueTeam"
}
variable "team-name-caps" {
  default = "REDTEAM"
  #default = "BLUETEAM"
}

variable "team-region" {
  default = "West US"
}

variable "network-1-cidr" {
  default = "10.0.0.0/16"
}

variable "net-1-subnet-1-cidr" {
  default = "10.0.0.0/24"
}

variable "id-rsa-keyname" {
  default = "id_rsa_redteam"
}

variable "ansible-start" {
  default = "sudo docker run --mount type=bind,src=/home/azureuser/.ssh,dst=/root/.ssh --mount type=bind,src=/home/azureuser/ansible,dst=/etc/ansible  -it cyberxsecurity/ansible /bin/bash"
}

variable "ubuntu-sku" {
  default = "18.04-LTS"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}

data "terraform_remote_state" "blueteam" {
  backend = "local"

  config {
    path = "/Downloads/blueteam/terraform.tfstate"
  }
}


resource "azurerm_network_security_group" "blueteam" {
  name                = "${var.team-name-mix}-SG"
  location            = blueteam.azurerm_resource_group.blueteam.location
  resource_group_name = blueteam.azurerm_resource_group.blueteam.name

  security_rule {
    access = "Deny"
    direction = "Inbound"
    name = "Default-Deny"
    priority = 4096
    protocol = "*"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    access = "Allow"
    direction = "Inbound"
    name = "Allow-SSH-for-Jumpbox"
    priority = 500
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = var.home_ip
    destination_port_range = "22"
    destination_address_prefix = "*"
  }

  tags = {
    "CostCenter" = "0001"
    "Application" = "ELK"
  }
}

