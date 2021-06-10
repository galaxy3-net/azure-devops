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

variable "network_cidrs" {
  type = map(string)
  default = {
    "RedTeam-Net" = "10.0.0.0/16",
    "BlueTeam-Net" = "10.1.0.0/16",
  }
}

variable "resource_tags" {}


output "network-cidrs" {
  value = var.network_cidrs
}

output "resource_tags" {
  value = var.resource_tags
}