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
    destination_address_prefix = azurerm_network_interface.jumpbox.private_ip_address
  }

  security_rule {
    access = "Allow"
    direction = "Inbound"
    name = "Allow-SSH-from-Jumpbox"
    priority = 501
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = azurerm_network_interface.jumpbox.private_ip_address
    destination_port_range = "22"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    access = "Allow"
    direction = "Inbound"
    name = "Allow-Web"
    priority = 502
    protocol = "TCP"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "80"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = var.resource_tags
}
