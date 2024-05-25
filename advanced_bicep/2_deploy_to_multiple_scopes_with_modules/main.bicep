targetScope = 'subscription'
param virtualNetworkname string
param virtualNetworkAddressPrefix string

var policyDefinitionName = 'DenyFandGServicesVMs'
var policyAssignmentName = 'DenyFandGSeriesVMs'
var resourceGroupName = 'ToyNetworking'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: policyDefinitionName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                like: 'Standard_F*'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                like: 'Standard_G*'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
  
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' ={
  name: policyAssignmentName
  properties: {
    policyDefinitionId: policyDefinition.id
  }
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: deployment().location
}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: 'virtualNetwork'
  params: {
    virtualNetworkName: virtualNetworkname
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
  }
}
