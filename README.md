# azure-devops
Azure DevOps

[Add a Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)



Install Azure CLI
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
[Install Terraform](https://www.terraform.io/docs/cli/install/apt.html)

Install Minikube
```
On Windows

choco install minikube

On MacOS

brew install minikube
```

Install Helm
```
On Windows

choco install kubernetes-helm

On MacOS

brew install kubernetes-helm
```

```
az login
az account list
az account set --subscription="SUBSCRIPTION_ID"
```
Create the Service Principal
```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```



[Setup Communication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)

[Example Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)