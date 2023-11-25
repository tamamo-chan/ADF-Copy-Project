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

resource managedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: 'default'
  parent: dataFactory
  properties: {
    preventDataExfiltration: false
  }
}

// -------------------------------------------------------- //
// Output
// -------------------------------------------------------- //

output name string = managedVnet.name
