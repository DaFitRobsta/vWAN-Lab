param vWANname string
param vWANHubName string
param vWANHubAddressPrefix string
param vpnSiteName string
param vpnSiteASN int
param vpnSitebgpPeeringAddress string
param vpnsitePublicIPAddress string
param vpnGatewayName string
param vpnGatewayScaleUnit int
param vpnConnectionName string
param location string

resource vwan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: vWANname
  location: location
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: 'Standard'
  }  
}

resource vwanHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: vWANHubName
  location: location
  dependsOn: []
  properties: {
    addressPrefix: vWANHubAddressPrefix
    virtualWan: {
      id: vwan.id 
    }
  }
}

resource vpnSite 'Microsoft.Network/vpnSites@2021-02-01' = {
  name: vpnSiteName
  location: location
  dependsOn: []
  properties: {
    addressSpace: {
      addressPrefixes: []
    }
    deviceProperties: {
      deviceVendor: 'Microsoft'
      linkSpeedInMbps: 0
    }
    virtualWan: {
      id: vwan.id
    }
    bgpProperties: {
      asn: vpnSiteASN
      bgpPeeringAddress: vpnSitebgpPeeringAddress
      peerWeight: 0
    }
    ipAddress: vpnsitePublicIPAddress
  }
}

resource vpnGateway 'Microsoft.Network/vpnGateways@2021-02-01' = {
  name: vpnGatewayName
  location: location
  dependsOn: [
    vwan
  ]
  properties: {
    connections: [
      {
        name: vpnConnectionName
        properties: {
          connectionBandwidth: 100
          enableBgp: true
          remoteVpnSite: {
            id: vpnSite.id 
          }
          sharedKey: 'rolightn3494'
          vpnConnectionProtocolType: 'IKEv2'
          usePolicyBasedTrafficSelectors: false
        }
      }
    ]
    virtualHub: {
      id: vwanHub.id
    }
    bgpSettings: {
      asn: 65515
    }
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
  }
}

output vpnGatewayPublicIP00 string = vpnGateway.properties.ipConfigurations[0].publicIpAddress
output vpnGatewayPublicIP01 string = vpnGateway.properties.ipConfigurations[1].publicIpAddress
