// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param privateEndpointName string

param managedVnetName string

param storageAccountId string

param dataFactoryName string

// -------------------------------------------------------- //
// Required resources
// -------------------------------------------------------- //

resource managedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' existing = {
  name: managedVnetName
  parent: dataFactory
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource AzureBlobStorageSource 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: privateEndpointName
  parent: managedVnet
  properties: {
    privateLinkResourceId: storageAccountId
    groupId: 'blob'
    connectionState: {}
  }
}
