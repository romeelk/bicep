# Deploying Sentinel with Bicep

The follwing bicep file originates from a MS learn tutorial at
https://raw.githubusercontent.com/MicrosoftDocs/mslearn-security-ops-sentinel/main/mslearn-hunt-threats-sentinel/sentinel-template.json

It has been decompiled using the command
```
az bicep decompile -f sentinel.json
```

The file can be adapted to add Sentinel queries, a sample Linux vm to simulate rogue VM listing storage account as well.

## Running the commands

Create RG:
```
RGNAME=rg-uks-sentinel
LOCATION=uksouth
 az group create --location $LOCATION --resource-group $RGNAME
 az configure --defaults group=$RGNAME
```

Deploy the bicep file:

```
az deployment group create \
  --template-file sentinel.bicep \
  --parameters workspaceName=rk-sentinel simpleVmAdminPassword=astrongpassword
```