// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param dataFactoryName string

// -------------------------------------------------------- //
// Required resources
// -------------------------------------------------------- //

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource integrationRuntimeManagedVnet 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: 'integrationRuntimeManagedVnet'
  parent: dataFactory
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'West Europe'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 8
          timeToLive: 10
          cleanup: false
          customProperties: []
        }
        pipelineExternalComputeScaleProperties: {
          timeToLive: 60
          numberOfPipelineNodes: 1
          numberOfExternalNodes: 1
        }
      }
    }
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
  }
}

output name string = integrationRuntimeManagedVnet.name
