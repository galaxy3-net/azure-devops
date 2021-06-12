resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = data.terraform_remote_state.redteam.outputs.rg-name
  virtual_network_name      = azurerm_virtual_network.net0.name
  remote_virtual_network_id = data.terraform_remote_state.redteam.outputs.redteam-net0-id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = data.terraform_remote_state.redteam.outputs.rg-name
  virtual_network_name      = data.terraform_remote_state.redteam.outputs.redteam-net0-name
  remote_virtual_network_id = azurerm_virtual_network.net0.id
}
