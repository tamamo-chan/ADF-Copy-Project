// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param dataFactoryName string

param location string

param tags object

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location 
  tags: tags
}

output id string = dataFactory.id
output name string = dataFactory.name
