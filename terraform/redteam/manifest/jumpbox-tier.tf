resource "azurerm_public_ip" "jumpbox" {
  allocation_method = "Dynamic"
  location = azurerm_resource_group.rg1.location
  name = "Jumpbox-IP"
  resource_group_name = azurerm_resource_group.rg1.name
  tags = var.resource_tags
}

resource "azurerm_network_interface" "jumpbox" {
  location = azurerm_resource_group.rg1.location
  name = "Jumpbox"
  resource_group_name = azurerm_resource_group.rg1.name
  internal_dns_name_label = "jumpbox"
  ip_configuration {
    name = "jumpbox-nic1"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jumpbox.id
  }
  tags = var.resource_tags
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  admin_username = "azureuser"
  location = azurerm_resource_group.rg1.location
  name = "Jumpbox"
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  resource_group_name = azurerm_resource_group.rg1.name
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

  provisioner "file" {
    source  = "${path.module}/../ansible"
    destination = "ansible"

    connection {
      type = "ssh"
      user = "azureuser"
      private_key = file("~/.ssh/${var.id-rsa-keyname}")
      host = self.public_ip_address
    }
  }

  provisioner "remote-exec" {
    script = "../files/bin/jumpbox-setup.sh"

    connection {
      type = "ssh"
      user = "azureuser"
      private_key = file("~/.ssh/${var.id-rsa-keyname}")
      host = self.public_ip_address
    }
  }

  custom_data = filebase64("${path.module}/../cloud-init.sh")
  tags = var.resource_tags
}

output "jumpbox-fqdn" {
  value = azurerm_public_ip.jumpbox.fqdn
}

output "jumpbox-public-ip" {
  value = azurerm_public_ip.jumpbox.ip_address
}

output "jumbox-private-ip" {
  value = azurerm_network_interface.jumpbox.private_ip_address
}
