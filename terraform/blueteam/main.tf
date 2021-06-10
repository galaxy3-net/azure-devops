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

terraform {
  backend "local" {
    path = "/Downloads/blueteam/terraform.tfstate"
  }
}

resource "azurerm_resource_group" "blueteam" {
  location = var.team-region
  name = var.team-name-mix

  tags = {
    "CostCenter" = "0001"
    "Application" = "ELK"
  }
}

resource "azurerm_network_security_group" "blueteam" {
  name                = "${var.team-name-mix}-SG"
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
    source_address_prefix = var.home_ip
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
  address_space = [var.network-1-cidr]
  location = azurerm_resource_group.blueteam.location
  name = "${var.team-name-mix}-Net"
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
  address_prefixes = [var.net-1-subnet-1-cidr]

}

resource "azurerm_public_ip" "jumpbox" {
  allocation_method = "Static"
  location = azurerm_resource_group.blueteam.location
  name = "Jumpbox-IP"
  resource_group_name = azurerm_resource_group.blueteam.name
}

resource "azurerm_network_interface" "jumpbox" {
  location = azurerm_resource_group.blueteam.location
  name = "Jumpbox"
  resource_group_name = azurerm_resource_group.blueteam.name
  internal_dns_name_label = "jumpbox"
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
    sku = var.ubuntu-sku
    version = "latest"
  }

  admin_ssh_key {
    public_key = file("~/.ssh/${var.id-rsa-keyname}.pub")
    username = "azureuser"
  }

  provisioner "file" {
    source = "~/.ssh/${var.id-rsa-keyname}_ansible"
    destination = "~/.ssh/${var.id-rsa-keyname}_ansible"

    connection {
      type = "ssh"
      user = "azureuser"
      private_key = file("~/.ssh/${var.id-rsa-keyname}")
      host = self.public_ip_address
    }
  }

#    provisioner "remote-exec" {
#      inline = [
#        "sudo systemctl enable docker",
#        "sudo systemctl start docker",
#        var.ansible-start,
#      ]

#      connection {
#        type = "ssh"
#        user = "azureuser"
#        private_key = file("~/.ssh/${var.id-rsa-keyname}")
#        host = self.public_ip_address
#      }
#  }

  provisioner "file" {
    source  = "${path.module}/ansible"
    destination = "ansible"

    connection {
      type = "ssh"
      user = "azureuser"
      private_key = file("~/.ssh/${var.id-rsa-keyname}")
      host = self.public_ip_address
    }
  }

  custom_data = filebase64("${path.module}/cloud-init.sh")
}

resource "azurerm_availability_set" "blueteam" {
  name                = "${var.team-name-mix}-AS"
  location            = azurerm_resource_group.blueteam.location
  resource_group_name = azurerm_resource_group.blueteam.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "web" {
  count = 2

  location = azurerm_resource_group.blueteam.location
  name = "web-${count.index}"
  resource_group_name = azurerm_resource_group.blueteam.name
  internal_dns_name_label = "web-${count.index}"
  ip_configuration {
    name = "${var.id-rsa-keyname}web-nic1"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  count = 2

  admin_username = "sysadmin"
  location = azurerm_resource_group.blueteam.location
  name = "Web-${count.index}"
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  resource_group_name = azurerm_resource_group.blueteam.name
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
    public_key = file("~/.ssh/${var.id-rsa-keyname}.pub")
    username = "sysadmin"
  }
}

resource "azurerm_public_ip" "blueteam" {
  name                = "${var.team-name-mix}-pip"
  location            = azurerm_resource_group.blueteam.location
  resource_group_name = azurerm_resource_group.blueteam.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "blueteam" {
  name                = "${var.team-name-mix}-lb"
  location            = azurerm_resource_group.blueteam.location
  resource_group_name = azurerm_resource_group.blueteam.name

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.blueteam.id
  }
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