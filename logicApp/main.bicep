param subscriptionId string
param name string
param location string
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool
param use32BitWorkerProcess bool
param storageAccountName string
param netFrameworkVersion string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string

resource name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/3691947b-a7bf-42a9-bac3-a1e8bad95287/resourceGroups/logicaapp-rom/providers/Microsoft.Insights/components/testapprom'
  }
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    name: name
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference('microsoft.insights/components/testapprom', '2015-05-01').InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference('microsoft.insights/components/testapprom', '2015-05-01').ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountName_resource.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${toLower(name)}b196'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
      ]
      cors: {}
      use32BitWorkerProcess: use32BitWorkerProcess
      netFrameworkVersion: netFrameworkVersion
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
  }
  dependsOn: [
    testapprom
    hostingPlanName_resource
  ]
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  tags: {}
  sku: {
    Tier: sku
    Name: skuCode
  }
  kind: ''
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    maximumElasticWorkerCount: '20'
    zoneRedundant: false
  }
  dependsOn: []
}

resource testapprom 'microsoft.insights/components@2020-02-02-preview' = {
  name: 'testapprom'
  location: 'uksouth'
  tags: {}
  properties: {
    ApplicationId: name
    Request_Source: 'IbizaWebAppExtensionCreate'
    Flow_Type: 'Redfield'
    Application_Type: 'web'
    WorkspaceResourceId: '/subscriptions/3691947b-a7bf-42a9-bac3-a1e8bad95287/resourceGroups/DefaultResourceGroup-SUK/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-3691947b-a7bf-42a9-bac3-a1e8bad95287-SUK'
  }
  dependsOn: []
}

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  tags: {}
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}
