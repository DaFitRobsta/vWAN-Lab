// Parameters for Virtual WAN
@description('Azure Virtual WAN Name')
param vWANname string

@description('VPN Connection Name from onprem to vWAN')
param vpnConnectionName string = 'onprem-to-azure'

@description('VPN Gateway Name')
param vpnGatewayName string

@description('Scale Units for Site-to-Site (S2S) VPN Gateway in the Hub')
param vpnGatewayScaleUnit int = 1

@description('On-Prem VPN Site Router\'s ASN')
param vpnSiteASN int = 65414

@description('Name of the on-prem VPN site')
param vpnSiteName string

@description('Name of the on-prem router/server')
param onPremVMName string = 'timbuktu'

@description('Provide a local admin username for the server')
param adminUsername string

@description('Admin password for the local admin account')
@secure()
param adminPassword string

@description('Set the timezone of your region. To get timezones, run this from PowerShell [System.TimeZoneInfo]::GetSystemTimeZones() | select id')
param autoShutdownTimeZone string = 'US Mountain Standard Time'

@description('Specify the VM SKU')
param vmSize string = 'Standard_B2s'

param osDiskType string = 'StandardSSD_LRS'

// Parameters for VNETs
var location = resourceGroup().location

// vWAN config
var vhub_cfg = {
  name: 'vhub01'
  addressSpacePrefix: '192.168.0.0/24'
}

module createVNets 'Network/00.vnets.bicep' = {
  name: 'createVNets'
  params: {
    location: location
    vWANname: vWANname
  }  
}

// TESTING creation of NSG
module createOnPremVmNSG 'Compute/00.onpremRouter.bicep' = {
  name: 'createOnPremVmNSG'
  params: {
    vmName: onPremVMName 
    location: location
    subnetRef: createVNets.outputs.onpremVnetSubnetRef
    adminUsername: adminUsername
    adminPassword: adminPassword
    autoShutdownTimeZone: autoShutdownTimeZone
    vmSize: vmSize
    osDiskType: osDiskType
  }
  
}
/*
// Create Virtual WAN with hub and vpn gateway
module createVWAN 'Network/01.vwan.bicep' = {
  name: 'createvWAN'
  params: {
    location: location
    vpnConnectionName: vpnConnectionName
    vpnGatewayName: vpnGatewayName
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    vpnSiteASN: vpnSiteASN
    vpnSitebgpPeeringAddress: '172.1.0.4' // need the private IP address of the onprem router vm
    vpnSiteName: vpnSiteName
    vpnsitePublicIPAddress: '20.38.168.218'  // need the public IP address of the onprem route vm
    vWANHubName: vhub_cfg.name
    vWANHubAddressPrefix: vhub_cfg.addressSpacePrefix
    vWANname: vWANname
  }
  
}
*/
