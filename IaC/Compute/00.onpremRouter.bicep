param vmName string = 'timbuktu'
param location string
param subnetRef string
param vmSize string = 'Standard_B2s'
param osDiskType string = 'StandardSSD_LRS'
param adminUsername string = 'adm.infra.usr'
@secure()
param adminPassword string
param patchMode string = 'AutomaticByOS'
param autoShutdownTimeZone string = 'US Mountain Standard Time'
param autoShutdownNotificationLocale string = 'en'

var nsgName = '${vmName}-nsg'
var nsgRules = [
  {
    name:'RDP'
    properties: {
        priority:300
        protocol:'Tcp'
        access:'Allow'
        direction:'Inbound'
        sourceAddressPrefix:'*'
        sourcePortRange:'*'
        destinationAddressPrefix:'*'
        destinationPortRange:'3389'
    }
  }
]

var pipName = '${vmName}-pip'
var nicName = '${vmName}-nic'

//Create NSG for on-prem router
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: nsgRules
  }
}

// Create the Publc IP address for the on-prem router
resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
output pipIPaddress string = pip.properties.ipAddress

// Create the NIC for the on-prem router
resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  dependsOn: []
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// Create the on-prem router VM
resource onpremVM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: patchMode
        }
      }
    }
    licenseType: 'Windows_Server'
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
output adminUsername string = adminUsername

resource shutdownVM 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '19:00'
    }
    timeZoneId: autoShutdownTimeZone
    targetResourceId: onpremVM.id
    notificationSettings: {
      status: 'Disabled'
      notificationLocale: autoShutdownNotificationLocale
      timeInMinutes: 30
    }
  }  
}
