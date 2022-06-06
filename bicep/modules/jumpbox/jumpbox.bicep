@secure()
param adminUsername string
@secure()
param adminPassword string

param subnetId string

param location string

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'jumpboxpip'
  location: location
  properties: {
      publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
      name: 'Basic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'jumpnic'
  location: location
  dependsOn: [
      pip
  ]
  properties: {
      ipConfigurations: [
          {
              name: 'ipconfig'
              properties: {
                  privateIPAllocationMethod: 'Dynamic'
                  publicIPAddress: {
                      id: pip.id
                  }
                  subnet:{
                      id: subnetId
                  }
              }
          }
      ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'jumpbox'
  location: location
  tags: {
    'aks-dev-secops': 'jumpbox'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {    
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18_04-lts-gen2'
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
      computerName: 'runner'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {        
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
      customData: loadFileAsBase64('runner-cloud-init.yaml')
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output vmName string = vm.name
output privateIps string = nic.properties.ipConfigurations[0].properties.privateIPAddress  
