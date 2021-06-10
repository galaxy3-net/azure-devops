# Configure the Microsoft Azure Provider


provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "rg1" {
  location = var.team-region
  name = var.team-name-mix

  tags = var.resource_tags
}




output "rg-name" {
  value = azurerm_resource_group.rg1.name
}

output "rg-location" {
  value = azurerm_resource_group.rg1.location
}
