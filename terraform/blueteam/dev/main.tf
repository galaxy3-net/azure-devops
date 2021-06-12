# Configure the Microsoft Azure Provider


provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}

data "terraform_remote_state" "redteam" {
  backend = "local"

  config = {
    path = "/Users/korbenkirscht/Downloads/terraform/redteam/dev/terraform.tfstate"
  }
}


