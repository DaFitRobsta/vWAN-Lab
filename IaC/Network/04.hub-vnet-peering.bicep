@description('Name of the Virtual Hub.')
param vHubName string

@description('Subnet Resource ID')
param vnetId string

param vnetName string


// Only create hub to spoke peerings
resource vnetHubPeeringToRemoteVnet 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-05-01' = {
  name: '${vHubName}/${vnetName}_connection'
  properties: {
    remoteVirtualNetwork: {
      id: vnetId
    }
  }
}
