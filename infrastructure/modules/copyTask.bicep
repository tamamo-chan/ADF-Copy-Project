// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param dataFactoryName string

param storageAccountNameSource string

param storageAccountNameSink string

param resourceGroupSink string

param containerNameSource string

param folderPathSource string

param containerNameSink string

param folderPathSink string

param fileName string

param integrationRuntimeName string

// -------------------------------------------------------- //
// Required resources
// -------------------------------------------------------- //

resource storageAccountSource 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountNameSource
}

resource storageAccountSink 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountNameSink
  scope: resourceGroup(resourceGroupSink)
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// -------------------------------------------------------- //
// Variables
// -------------------------------------------------------- //

var accountKeySource = storageAccountSource.listKeys().keys[0].value

var accountKeySink = storageAccountSink.listKeys().keys[0].value

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource linkedServiceSource 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'StorageSource'
  parent: dataFactory
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountSource.name};AccountKey=${accountKeySource};EndpointSuffix=core.windows.net'
    }
    connectVia: {
      referenceName: integrationRuntimeName
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedServiceSink 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'StorageSink'
  parent: dataFactory
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountSink.name};AccountKey=${accountKeySink};EndpointSuffix=core.windows.net'
    }
    connectVia: {
      referenceName: integrationRuntimeName
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource datasetSource 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'BlobDatasetSource'
  parent: dataFactory
  properties: {
    type: 'AzureBlob'
    linkedServiceName: {
      referenceName: linkedServiceSource.name
      type: 'LinkedServiceReference'
    }
    typeProperties: {
      folderPath: '${containerNameSource}/${folderPathSource}'
      fileName: fileName
    }
  }
}

resource datasetSink 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'BlobDatasetSink'
  parent: dataFactory
  properties: {
    type: 'AzureBlob'
    linkedServiceName: {
      referenceName: linkedServiceSink.name
      type: 'LinkedServiceReference'
    }
    typeProperties: {
      folderPath: '${containerNameSink}/${folderPathSink}'
      fileName: fileName
    }
  }
}

resource copyActivity 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'BlobCopyActivity'
  parent: dataFactory
  properties: {
    activities: [
      {
        name: 'CopyFromBlobToBlob'
        type: 'Copy'
        linkedServiceName: linkedServiceSource
        typeProperties: {
          source: {
            type: 'BlobSource'
            sourceRetryCount: 3
          }
          sink: {
            type: 'BlobSink'
            writeBatchSize: 0
            writeBatchTimeout: 'PT0S'
            sinkRetryCount: 3
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: datasetSource.name
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: datasetSink.name
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
}
