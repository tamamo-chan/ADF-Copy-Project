targetScope='subscription'

// -------------------------------------------------------- //
// Parameters
// -------------------------------------------------------- //

param location string = 'westeurope'

param tags object

param resourceGroupNameSource string

param resourceGroupNameSink string

param containerNameSource string

param containerNameSink string

@description('Folder to copy files from')
param folderPathSource string

@description('Folder to upload files')
param folderPathSink string

@description('Specific file to copy, leave empty if folder copy')
param fileName string

param allowedIp string

// -------------------------------------------------------- //
// Variables
// -------------------------------------------------------- //

var projectName = 'energinet'
var dataFactoryName = 'adf-${projectName}-01'
var storageAccNameSource = 'st${projectName}sourceprd01'
var storageAccNameSink = 'st${projectName}sinkprd01'
var dnsZoneName = 'blob.core.windows.net'
var subnetNameSource = 'snet-${projectName}-source-prd-01'
var subnetNameSink = 'snet-${projectName}-sink-prd-01'
var subnetPrefixSource = '10.0.0.0/29'
var subnetPrefixSink = '10.0.1.0/29'
var vnetNameSource = 'vnet1'
var vnetNameSink = 'vnet2'
var vnetPrefixSource = ['10.0.0.0/28']
var vnetPrefixSink = ['10.0.1.0/28']
var privateEndpointNameSource = 'pep-${projectName}-source-prd-01'
var privateEndpointNameSink = 'pep-${projectName}-sink-prd-01'

// -------------------------------------------------------- //
// Source resources
// -------------------------------------------------------- //

module resGroupSource 'modules/resourceGroup.bicep' = {
  name: 'ResourceGroupSource'
  scope: subscription()
  params: {
    resourceGroupLocation: location
    resourceGroupName: resourceGroupNameSource
    tags: tags
  }
}

module storageAccountSource 'modules/storageAccount.bicep' = {
  name: 'StorageAccountSource'
  scope: resourceGroup(resourceGroupNameSource)
  params: {
    location: location
    storageAccountName: storageAccNameSource 
    tags: tags
    containerName: containerNameSource
    allowedIp: allowedIp
  }
  dependsOn: [
    resGroupSource
    vnetSource
  ]
}

module dataFactory 'modules/dataFactory.bicep' = {
  name: 'DataFactory'
  scope: resourceGroup(resourceGroupNameSource)
  params: {
    dataFactoryName: dataFactoryName
    location: location
    tags: tags
  }
  dependsOn: [
    resGroupSource
  ]
} 

module integrationRuntime 'modules/integrationRuntime.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'IntegrationRuntime'
  params: {
    dataFactoryName: dataFactory.outputs.name
  }
  dependsOn: [
    managedVnet
  ]
}

// -------------------------------------------------------- //
// Sink resources
// -------------------------------------------------------- //

module resGroupSink 'modules/resourceGroup.bicep' = {
  name: 'ResourceGroupSink'
  scope: subscription()
  params: {
    resourceGroupLocation: location
    resourceGroupName: resourceGroupNameSink
    tags: tags
  }
}

module storageAccountSink 'modules/storageAccount.bicep' = {
  name: 'StorageAccountSink'
  scope: resourceGroup(resourceGroupNameSink)
  params: {
    location: location
    storageAccountName: storageAccNameSink 
    tags: tags
    containerName: containerNameSink
    allowedIp: allowedIp
  }
  dependsOn: [
    resGroupSink
    vnetSink
  ]
}

// -------------------------------------------------------- //
// Networking
// -------------------------------------------------------- //

module vnetSource 'modules/vnet.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'vnetSource'
  params: {
    dnsZoneName: dnsZoneName
    location: location
    subnetName: subnetNameSource
    subnetPrefix: subnetPrefixSource
    tags: tags
    vnetName: vnetNameSource
    vnetPrefix: vnetPrefixSource
  }
  dependsOn: [
    resGroupSource
  ]
}

module vnetSink 'modules/vnet.bicep' = {
  scope: resourceGroup(resourceGroupNameSink)
  name: 'vnetSink'
  params: {
    dnsZoneName: dnsZoneName
    location: location
    subnetName: subnetNameSink
    subnetPrefix: subnetPrefixSink
    tags: tags
    vnetName: vnetNameSink
    vnetPrefix: vnetPrefixSink
  }
  dependsOn: [
    resGroupSink
  ]
}

module privateEndpointSource 'modules/privateEndpoint.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'privateEndpointSource'
  params: {
    location: location
    privateEndpointName: privateEndpointNameSource
    storageAccountName: storageAccountSource.outputs.storageAccountName
    subnetId: vnetSource.outputs.subnetId
    tags: tags
  }
}

module privateEndpointSink 'modules/privateEndpoint.bicep' = {
  scope: resourceGroup(resourceGroupNameSink)
  name: 'privateEndpointSink'
  params: {
    location: location
    privateEndpointName: privateEndpointNameSink
    storageAccountName: storageAccountSink.outputs.storageAccountName
    subnetId: vnetSink.outputs.subnetId
    tags: tags
  }
}

module managedVnet 'modules/managedVnet.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'ManagedVnet'
  params: {
    dataFactoryName: dataFactory.outputs.name
  }
}

module managedPrivateEndpointSource 'modules/managedPrivateEndpoint.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'ManagedPrivateEndpointSource'
  params: {
    managedVnetName: managedVnet.outputs.name
    privateEndpointName: 'AzureBlobStorageSource'
    storageAccountId: storageAccountSource.outputs.id
    dataFactoryName: dataFactory.outputs.name
  }
}

module managedPrivateEndpointSink 'modules/managedPrivateEndpoint.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'ManagedPrivateEndpointSink'
  params: {
    managedVnetName: managedVnet.outputs.name
    privateEndpointName: 'AzureBlobStorageSink'
    storageAccountId: storageAccountSink.outputs.id
    dataFactoryName: dataFactory.outputs.name
  }
}

// -------------------------------------------------------- //
// Tasks
// -------------------------------------------------------- //

module copyTask 'modules/copyTask.bicep' = {
  scope: resourceGroup(resourceGroupNameSource)
  name: 'CopyTask'
  params: {
    containerNameSink: containerNameSink
    containerNameSource: containerNameSource
    dataFactoryName: dataFactory.outputs.name
    fileName: fileName
    integrationRuntimeName: integrationRuntime.outputs.name
    resourceGroupSink: resGroupSink.outputs.name
    storageAccountNameSink: storageAccountSink.outputs.storageAccountName
    storageAccountNameSource: storageAccountSource.outputs.storageAccountName
    folderPathSource: folderPathSource
    folderPathSink: folderPathSink
  }
}

