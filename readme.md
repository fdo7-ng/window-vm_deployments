# Window VM Deployment 

This repo contains some basic example of a Windows VM can be deploying using various tools available.
Once the VM is configured basic configurations can be performed on the VM.

# Via PowerShell

# Via Terraform

This is a simple Terraform job to deploy a vm to exiting Resource Group and VNET.

```
# Prior to running Terraform commands need to be connected to Azure.
az login # Connect to Azure
az account set --subscription "Subscription_Name" # Select Proper subcription
az account show # To check


# To gets started with terraform must have a tfvars file with values populated.

> terraform init  # To initialize
> terraform plan -var-file='dev.tfvars' # To Plan no output just for verification
> terraform apply -var-file='dev.tfvars' # Will Ask for Configmation

# With output File
> terraform plan -var-file='dev.tfvars' -out 'deploy.tfplan' # To Plan, produce deploy.tfplan 
> terraform apply deploy.tfplan # Passing deploy.tfplan

# To Destroy all resources create 
> terraform apply -var-file='dev.tfvars' -destroy # will ask for confirmation
```

## More Example https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure


# Via ARM Template