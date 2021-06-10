variable "network_cidrs" {
  type = map(string)
  default = {
    "RedTeam-Net" = "10.0.0.0/16",
    "BlueTeam-Net" = "10.1.0.0/16",
  }
}