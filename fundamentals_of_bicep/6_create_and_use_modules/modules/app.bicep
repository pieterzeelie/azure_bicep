@description('The Azure region into which the resource should be deployed.')
param location string

@description('The name of the App Service App.')
param appServiceAppName string

@description('The name of the app service plan.')
param appServicePlanName string

@description('The name of the App Service plan Sku.')
param appServicePlanSkuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

@description('The default host name of the App Service app.')
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
