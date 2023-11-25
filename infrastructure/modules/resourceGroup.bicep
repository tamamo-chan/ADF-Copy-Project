targetScope='subscription'

// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param resourceGroupName string

param resourceGroupLocation string

param tags object

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: tags
}

// -------------------------------------------------------- //
// Output
// -------------------------------------------------------- //

output name string = resourceGroup.name
output id string = resourceGroup.id
