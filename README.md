# Azure bicep

After doing Terraform for a while it is time to look at Azure Bicep.

# Pre-requesites

* VSCode
* Azure CLI
* Azure subscription
* Azure Bicep cli

# Install Bicep

Install bicep:

```
az bicep install && az bicep upgrade
```
# Starter

Create a folder for your bicep files

```
mkdir bicep
cd bicep
```

Make sure you install the VSCode extension

![VScode exntension](vscodebicep.png)


# Basic structure

Create a file called main.bicep.

The VSCode extension has intellisense built in. 

Start typing storage and you will intellisense will bring up the bicep storage resource. Tab for completion and you will get a completed block:

```
@allowed([
  'nonprod'
  'prod'
])
param environmentType string
param location string  = resourceGroup().location

param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

var appServicePlanName = 'toy-product-launch-plan'
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS': 'Standard_LRS'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_v3' : 'F1'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}


```

To pass parameters into the block above the resource block add two parameters for storageAccountName and storageAccountLocation

```
@allowed([
  'nonprod'
  'prod'
])
param environmentType string
param location string  = resourceGroup().location

param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

```


## Deploy the template

```
RGBNAME=rg-uks-storage
 az group create --name $RGNAME --location uksouth
 az configure --defaults group=$RGNAME
```

Deploy bicep template:

```
az deployment group create --template-file main.bicep
```

Verify deployment:

```
az deployment group list --output table
```

Deploy template with parameter:

```
az deployment group create \
  --template-file main.bicep \
  --parameters environmentType=nonprod

```

What if verify

```
az deployment group create --what-if  \
  --template-file main.bicep \
  --parameters environmentType=nonprod \
  --mode Complete
```

## Converting existing ARM to bicep

Use the following command:

```
az bicep decompile -f .\arm-template\arm-example.json
```

## Converting bicep to ARM


```
az bicep build --file main.bicep
```

## Running with Checkov

Checkov does not natively support bicep but rather supports ARM.

To run it just transpile your bicep to ARM json and run against directory as follows:

```
 docker run --tty --volume /Users/romeel.khan@contino.io/dev/bicep:/bicep --workdir /bicep bridgecrew/checkov --directory /bicep
```