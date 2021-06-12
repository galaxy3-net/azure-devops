resource "azurerm_network_security_group" "blueteam" {
  name                = "blueteam-SG"
  location            = "Central US"
  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name

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

  security_rule {
    access = "Allow"
    direction = "Inbound"
    name = "Allow-HTTP-for-ELK"
    priority = 501
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = var.home_ip
    destination_port_range = "80"
    destination_address_prefix = "*"
  }

  security_rule {
    access = "Allow"
    direction = "Inbound"
    name = "Allow-5601-for-ELK"
    priority = 502
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = var.home_ip
    destination_port_range = "5601"
    destination_address_prefix = "*"
  }

  tags = var.resource_tags
}

#
#  Do not use!!!
#resource "azurerm_network_ddos_protection_plan" "blueteam" {
#  name                = "blueteam-protection-plan"
#  location            = azurerm_resource_group.blueteam.location
#  resource_group_name = azurerm_resource_group.blueteam.name
#}


resource "azurerm_virtual_network" "net0" {
  address_space = [var.network_cidrs.BlueTeam-Net]
  location = azurerm_network_security_group.blueteam.location
  name = "${var.team-name-mix}-Net"
  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name

  #
  #  Do not use!!!
  #  ddos_protection_plan {
  #    enable = false
  #    id = azurerm_network_ddos_protection_plan.blueteam.id
  #  }

  tags = var.resource_tags

}

resource "azurerm_subnet" "default" {
  name = "default"
  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name
  virtual_network_name = azurerm_virtual_network.net0.name
  address_prefixes = [var.net-1-subnet-1-cidr]
}

