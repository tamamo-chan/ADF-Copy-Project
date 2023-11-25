// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param vnetName string

param location string

param tags object

param vnetPrefix string[]

param subnetName string

param subnetPrefix string

param dnsZoneName string

// -------------------------------------------------------- //
// New resources
// -------------------------------------------------------- //

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetPrefix
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: 'global'
  tags: tags
}
 
resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: uniqueString(virtualNetwork.id)
  parent: dnsZone
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

// -------------------------------------------------------- //
// Output
// -------------------------------------------------------- //

output subnetName string = virtualNetwork.properties.subnets[0].name
output subnetId string = virtualNetwork.properties.subnets[0].id
