# Deploy Development Environment #

Create credentials file (~/dev-terraform.vars)
```
#/ / / / / / / / / / / / / / / / / / / / / / / / / /
#  DANGER:  Do not ever place this file into any 
#           version control repository
#
#  This file contains secret credential information.
#/ / / / / / / / / / / / / / / / / / / / / / / / / / 

client_id = "< client / application id>"
client_secret = "< client secret / password >"
subscription_id="< subscription id >"
tenant_id="< tenant id / id >"

```

## Initilize the Terraform Config ##
```
terraform init ../manifest
```

## Create the Terraform Plan ##
```
terraform plan -var-file ~/galaxy3/Downloads/terraform.tfvars -out plan.out ../manifest/
```

## Apply the Terraform Plan ##
```
terraform apply "plan.out"
```

## Destroy the Terraform Deployment @@
```
terraform plan -destroy -var-file ~/galaxy3/Downloads/terraform.tfvars -out plan.out ../manifest/
terraform apply "plan.out"
```