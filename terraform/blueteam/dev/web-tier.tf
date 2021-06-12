#resource "azurerm_availability_set" "blueteam" {
#  name                = "${var.team-name-mix}-AS"
#  location            = azurerm_network_security_group.blueteam.location
#  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name
#
#  tags = var.resource_tags
#}

resource "azurerm_public_ip" "elk" {
  name                = "ELK-pip"
  location            = azurerm_network_security_group.blueteam.location
  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name
  allocation_method   = "Dynamic"
  tags = var.resource_tags
}

resource "azurerm_network_interface" "web" {
  count = 2

  location = azurerm_network_security_group.blueteam.location
  name = "elk-web-${count.index}"
  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name
  internal_dns_name_label = "elk-web-${count.index}"
  ip_configuration {
    name = "elk-web-nic1"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.elk.id
  }
  tags = var.resource_tags
}

resource "azurerm_linux_virtual_machine" "web" {
  count = 1

  admin_username = "sysadmin"
  location = azurerm_network_security_group.blueteam.location
  name = "Elk-Web-${count.index}"
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name
  # availability_set_id = azurerm_availability_set.blueteam.id
  size = "Standard_B1s"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer = "UbuntuServer"
    publisher = "Canonical"
    sku = var.ubuntu-sku
    version = "latest"
  }

  admin_ssh_key {
    public_key = file("~/.ssh/${var.id-rsa-keyname}.pub")
    username = "sysadmin"
  }
  tags = var.resource_tags
}



#resource "azurerm_lb" "blueteam" {
#  name                = "${var.team-name-mix}-lb"
#  location            = azurerm_network_security_group.blueteam.location
#  resource_group_name = data.terraform_remote_state.redteam.outputs.rg-name

#  frontend_ip_configuration {
#    name                 = "primary"
#    public_ip_address_id = azurerm_public_ip.blueteam.id
#  }
#  tags = var.resource_tags
#}

#resource "azurerm_lb_backend_address_pool" "blueteam" {
#  #resource_group_name = azurerm_resource_group.blueteam.name
#  loadbalancer_id     = azurerm_lb.blueteam.id
#  name                = "${var.team-name-mix}-pool"
#}

#resource "azurerm_network_interface_backend_address_pool_association" "example" {
#  count = 2
#
#  network_interface_id    = azurerm_network_interface.web[count.index].id
#  ip_configuration_name   = "${var.id-rsa-keyname}web-nic1"
#  backend_address_pool_id = azurerm_lb_backend_address_pool.blueteam.id
#}
