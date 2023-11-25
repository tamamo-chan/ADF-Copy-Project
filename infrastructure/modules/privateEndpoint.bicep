// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param storageAccountName string

param privateEndpointName string

param location string

param tags object

param subnetId string

// -------------------------------------------------------- //
// Required resources
// -------------------------------------------------------- //

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'storage'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
}
