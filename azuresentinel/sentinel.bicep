param workspaceName string
param location string = resourceGroup().location

@minLength(1)
param simplevmName string = 'simple-vm'
param simplevmWindowsOSVersion string = '2016-Datacenter'
param simpleVmAdminPassword string
param simpleVmAdminUser string = 'simplevmadmin'

var vnet1Prefix = '10.0.0.0/16'
var vnet1Subnet1Name = 'Subnet-1'
var vnet1Subnet1Prefix = '10.0.0.0/24'
var vnet1Subnet2Name = 'Subnet-2'
var vnet1Subnet2Prefix = '10.0.1.0/24'
var st1Name_var = 'st1${uniqueString(resourceGroup().id)}'
var st1Type = 'Standard_LRS'
var simplevmImagePublisher = 'MicrosoftWindowsServer'
var simplevmImageOffer = 'WindowsServer'
var simplevmOSDiskName = 'simplevmOSDisk'
var simplevmVmSize = 'Standard_D1_v2'
var simplevmVnetID = vnet1.id
var simplevmSubnetRef = '${simplevmVnetID}/subnets/${vnet1Subnet1Name}'
var simplevmStorageAccountContainerName = 'vhds'
var simplevmNicName_var = '${simplevmName}NetworkInterface'

resource workspaceName_resource 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    features: {
      immediatePurgeDataOn30Days: true
    }
    sku: {
      name: 'Free'
    }
  }
}

resource SecurityInsights_workspaceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspaceName})'
  location: location
  plan: {
    name: 'SecurityInsights(${workspaceName})'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspaceName_resource.id
  }
}

resource vnet1 'Microsoft.Network/virtualNetworks@2015-06-15' = {
  name: 'vnet1'
  location: resourceGroup().location
  tags: {
    displayName: 'vnet1'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1Prefix
      ]
    }
    subnets: [
      {
        name: vnet1Subnet1Name
        properties: {
          addressPrefix: vnet1Subnet1Prefix
        }
      }
      {
        name: vnet1Subnet2Name
        properties: {
          addressPrefix: vnet1Subnet2Prefix
        }
      }
    ]
  }
  dependsOn: []
}

resource st1Name 'Microsoft.Storage/storageAccounts@2015-06-15' = {
  name: st1Name_var
  location: resourceGroup().location
  tags: {
    displayName: 'st1'
  }
  properties: {
    accountType: st1Type
  }
  dependsOn: []
}

resource simplevmNicName 'Microsoft.Network/networkInterfaces@2015-06-15' = {
  name: simplevmNicName_var
  location: resourceGroup().location
  tags: {
    displayName: 'simplevmNic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: simplevmSubnetRef
          }
        }
      }
    ]
  }
}

resource simplevmName_resource 'Microsoft.Compute/virtualMachines@2015-06-15' = {
  name: simplevmName
  location: resourceGroup().location
  tags: {
    displayName: 'simplevm'
  }
  properties: {
    hardwareProfile: {
      vmSize: simplevmVmSize
    }
    osProfile: {
      computerName: simplevmName
      adminUsername: simpleVmAdminUser
      adminPassword: simpleVmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: simplevmImagePublisher
        offer: simplevmImageOffer
        sku: simplevmWindowsOSVersion
        version: 'latest'
      }
      osDisk: {
        name: 'simplevmOSDisk'
        vhd: {
          uri: 'http://${st1Name_var}.blob.core.windows.net/${simplevmStorageAccountContainerName}/${simplevmOSDiskName}.vhd'
        }
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: simplevmNicName.id
        }
      ]
    }
  }
  dependsOn: [
    st1Name
  ]
}
