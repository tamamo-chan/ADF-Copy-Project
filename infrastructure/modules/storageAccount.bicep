// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param location string

param tags object

param storageAccountName string

param containerName string

param allowedIp string

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: [
        {
          value: allowedIp
          action: 'Allow'
        }
      ]
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: containerName
  parent: blobServices
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

// -------------------------------------------------------- //
// Output
// -------------------------------------------------------- //

output id string = storageAccount.id
output storageAccountName string = storageAccount.name
output containerName string = container.name
