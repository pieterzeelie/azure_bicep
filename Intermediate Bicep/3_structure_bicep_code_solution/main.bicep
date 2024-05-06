@description('The loactaion that we are deployed our azure resourcesto. Default value is the location resource group.')
param location string = resourceGroup().location

@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])

@description('The name of the sku of our app service plan.')
param appServicePlanSkuName string = 'F1'

@description('Select the type of environment you want to provision. Allowed values are Production and Test.')
@allowed([
  'Production'
  'Test'
])
param environmentType string

@minValue(1)
@maxValue(5)
param appServicePlanSkuCapacity int = 1

@secure()
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

param managedIdentityName string = guid(contributorRoleDefinitionId, resourceGroup().id)

@description('The role definition id ofr the managed identity. Default value is Contributor Role ')
param contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

param webSiteName string = 'webSite${uniqueString(resourceGroup().id)}'

param storageAccountName string = 'toywebsite${uniqueString(resourceGroup().id)}'
var blobContainerNames = [
  'productSpecs'
  'productManuals'
]

var hostingPlanName = 'hostingplan${uniqueString(resourceGroup().id)}'
var sqlServerName = 'toywebsite${uniqueString(resourceGroup().id)}'


var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    StorageAccount: {
      sku: {
        name: 'Standard_GRS'
      }
    }
    sqlDatabase: {
       sku: {
        name: 'S1'
        tier: 'Standard'
       }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccoutn: {
      sky: {
        name: 'Standard_LRS'
      }
    }
    sqlDatabase: {
      sky: {
        name: 'Basic'
      }
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'

  resource containers 'containers' = [for blobContainerNames in blobContainerNames: {
    name: blobContainerNames
  }]  
  }
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

var databaseName = 'ToyCompanyWebsite'
resource sqlServerNameDatabaseName 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: environmentConfigurationMap[environmentType].sqlDatabase.sku
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource sqlServerNameAllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanSkuCapacity
  }
}

resource webSite 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: AppInsightsWebSiteName.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }
}

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(contributorRoleDefinitionId, resourceGroup().id)

  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: msi.properties.principalId
  }
}

resource AppInsightsWebSiteName 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
