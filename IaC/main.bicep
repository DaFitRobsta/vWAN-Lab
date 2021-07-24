// Parameters for Virtual WAN
@description('Azure Virtual WAN Name')
param vWANname string

@description('Scale Units for Site-to-Site (S2S) VPN Gateway in the Hub')
param hub_S2SvpnGatewayScaleUnit int = 1

// Parameters for VNETs
var location = resourceGroup().location

// vWAN config
var vwan_cfg = {
  type: 'Standard'
}
var vhub_cfg = {
  name: 'vhub01'
  addressSpacePrefix: '192.168.0.0/24'
}

module createVNets 'Network/vnets.bicep' = {
  name: 'createVNets'
  params: {
    location: location
    vWANname: vWANname
  }  
}
