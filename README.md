# Provision AKS cluster using Terraform via Service Principal

In this project, we will be creating AKS cluster the right way by using service principle.kubeconfig and service principle will be generated after the terraform plan and secret will be upload to keyvault to be used further.

## Below resources will be created using this terraform configuration:-
- Resource Group
- Service Principle
- AKS cluster using the SPN
- Azure key vault to store the client secret
- Secret uploaded to key vault
- kubeconfig for AKS


## Pre-requisites

- kubectl cli installed
- Azure CLI installed and logged in
- Storage Account and blob container created to store the tfstate file as backend, you can use below shell script as well

``` shell
#!/bin/bash

RESOURCE_GROUP_NAME=backend-rg
STORAGE_ACCOUNT_NAME=backendsa101
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location canadacentral

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```


## Usage/Examples

### 1) login to the CLI
```shell
az login --use-device-code
```

## Login to Azure

```
#login and follow prompts
az login --use-device-code

# view and select your subscription account

az account list -o table
SUBSCRIPTION=<id>
az account set --subscription $SUBSCRIPTION

```

### 2) set alias
```shell
alias tf=terraform
```
### 3) initialize the providers
```shell
tf init
```
### 4) Run the plan
```shell
tf plan
```
### 5) Apply the changes
```shell
tf apply --auto-approve
```