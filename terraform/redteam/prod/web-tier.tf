resource "azurerm_availability_set" "blueteam" {
  name                = "${var.team-name-mix}-AS"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = var.resource_tags
}

resource "azurerm_network_interface" "web" {
  count = 2

  location = azurerm_resource_group.rg1.location
  name = "web-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg1.name
  internal_dns_name_label = "web-${count.index + 1}"
  ip_configuration {
    name = "${var.id-rsa-keyname}web-nic1"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.resource_tags
}

resource "azurerm_linux_virtual_machine" "web" {
  count = 2

  admin_username = "sysadmin"
  location = azurerm_resource_group.rg1.location
  name = "Web-${count.index + 1}"
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  resource_group_name = azurerm_resource_group.rg1.name
  availability_set_id = azurerm_availability_set.blueteam.id
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
    public_key = file("~/.ssh/${var.id-rsa-keyname}_ansible.pub")
    username = "sysadmin"
  }
  tags = var.resource_tags
}

resource "azurerm_public_ip" "blueteam" {
  name                = "${var.team-name-mix}-pip"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  tags = var.resource_tags
}

resource "azurerm_lb" "blueteam" {
  name                = "${var.team-name-mix}-lb"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.blueteam.id
  }
  tags = var.resource_tags
}

resource "azurerm_lb_probe" "example" {
  resource_group_name = azurerm_resource_group.rg1.name
  loadbalancer_id     = azurerm_lb.blueteam.id
  name                = "ssh-running-probe"
  port                = 80
}

resource "azurerm_lb_backend_address_pool" "blueteam" {
  #resource_group_name = azurerm_resource_group.blueteam.name
  loadbalancer_id     = azurerm_lb.blueteam.id
  name                = "${var.team-name-mix}-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count = 2

  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = "${var.id-rsa-keyname}web-nic1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.blueteam.id
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.rg1.name
  loadbalancer_id                = azurerm_lb.blueteam.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.blueteam.id
  probe_id = azurerm_lb_probe.example.id
}

