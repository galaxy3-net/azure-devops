# Configure the Microsoft Azure Provider

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "home_ip" {}

provider "azurerm" {
  features {}
  subscription_id = "${var.subscription_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
}

resource "azurerm_resource_group" "blueteam" {
  location = "West US"
  name = "Blue-Team"

  tags = {
    "CostCenter" = "0001"
    "Application" = "ELK"
  }
}

resource "azurerm_network_security_group" "blueteam" {
  name                = "BlueTeam-SG"
  location            = azurerm_resource_group.blueteam.location
  resource_group_name = azurerm_resource_group.blueteam.name

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
    source_address_prefix = "${var.home_ip}"
    destination_port_range = "22"
    destination_address_prefix = "*"
  }

  tags = {
    "CostCenter" = "0001"
    "Application" = "ELK"
  }
}

#
#  Do not use!!!
#resource "azurerm_network_ddos_protection_plan" "blueteam" {
#  name                = "blueteam-protection-plan"
#  location            = azurerm_resource_group.blueteam.location
#  resource_group_name = azurerm_resource_group.blueteam.name
#}


resource "azurerm_virtual_network" "net0" {
  address_space = ["10.1.0.0/16"]
  location = azurerm_resource_group.blueteam.location
  name = "BlueNet"
  resource_group_name = azurerm_resource_group.blueteam.name

  #
  #  Do not use!!!
#  ddos_protection_plan {
#    enable = false
#    id = azurerm_network_ddos_protection_plan.blueteam.id
#  }

  tags = {
    "CostCenter" = "0001"
    "Application" = "ELK"
  }

}

resource "azurerm_subnet" "default" {
  name = "default"
  resource_group_name = azurerm_resource_group.blueteam.name
  virtual_network_name = azurerm_virtual_network.net0.name
  address_prefixes = ["10.1.0.0/24"]

}

resource "azurerm_public_ip" "jumpbox" {
  allocation_method = "Static"
  location = azurerm_resource_group.blueteam.location
  name = "Jumpvox-IP"
  resource_group_name = azurerm_resource_group.blueteam.name
}

resource "azurerm_network_interface" "jumpbox" {
  location = azurerm_resource_group.blueteam.location
  name = "Jumpbox"
  resource_group_name = azurerm_resource_group.blueteam.name
  ip_configuration {
    name = "jumpbox-nic1"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  admin_username = "azureuser"
  location = azurerm_resource_group.blueteam.location
  name = "Jumpbox"
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  resource_group_name = azurerm_resource_group.blueteam.name
  size = "Standard_B1s"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer = "UbuntuServer"
    publisher = "Canonical"
    sku = "16.04-LTS"
    version = "latest"
  }

  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa_redteam.pub")
    username = "azureuser"
  }
}
