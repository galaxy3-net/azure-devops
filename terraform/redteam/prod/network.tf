resource "azurerm_network_security_group" "blueteam" {
  name                = "${var.team-name-mix}-SG"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

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
    destination_address_prefix =
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
  address_space = [var.network_cidrs.RedTeam-Net]
  location = azurerm_resource_group.rg1.location
  name = "${var.team-name-mix}-Net"
  resource_group_name = azurerm_resource_group.rg1.name

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
  resource_group_name = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.net0.name
  address_prefixes = [var.net-1-subnet-1-cidr]
}

output "redteam-net0-id" {
  value = azurerm_virtual_network.net0.id
}

output "redteam-net0-name" {
  value = azurerm_virtual_network.net0.name
}
