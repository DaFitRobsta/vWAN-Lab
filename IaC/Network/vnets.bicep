param vWANname string
param location string

var hubconnected_vnets_cfg = [
  {
    name: 'vnet01-${uniqueString(vWANname)}'
    addressSpacePrefix: '10.1.0.0/24'
    subnetName: 'servers-sn'
    subnetPrefix: '10.1.0.0/25'
  }
  {
    name: 'vnet02-${uniqueString(vWANname)}'
    addressSpacePrefix: '10.2.0.0/24'
    subnetName: 'servers-sn'
    subnetPrefix: '10.2.0.0/25'
  }
]
var vnet_onprem_cfg = {
  name: 'vnet-on-prem-${uniqueString(vWANname)}'
  addressSpacePrefix: '172.1.0.0/16'
  subnetNames: [
    'router-sn'
    'servers-sn'
  ]
  subnetPrefixes: [
    '172.1.0.0/24'
    '172.1.1.0/24'
  ] 
}

resource hubVNets 'Microsoft.Network/virtualNetworks@2021-02-01' = [for vnet in hubconnected_vnets_cfg: {
  name: vnet.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: vnet.subnetName
        properties:{
          addressPrefix: vnet.subnetPrefix
        }
      }
    ]
  }
}]

resource onpremVNet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnet_onprem_cfg.name
  location: location
  dependsOn: [
    hubVNets
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_onprem_cfg.addressSpacePrefix
      ]
    }
    subnets: [for (subnet, i) in vnet_onprem_cfg.subnetNames: {
      name: subnet
      properties: {
        addressPrefix: vnet_onprem_cfg.subnetPrefixes[i]
      }
    }]
  }  
}
