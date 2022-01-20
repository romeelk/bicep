@minLength(3)
@maxLength(24)
param storageAccountName string
param storageLocation string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: storageLocation
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}
