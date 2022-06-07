/*
* Notice: Any links, references, or attachments that contain sample scripts, code, or commands comes with the following notification.
*
* This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
* THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
* INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
*
* We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
* provided that You agree:
*
* (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
* (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
* (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits,
* including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
*
* Please note: None of the conditions outlined in the disclaimer above will superseded the terms and conditions contained within the Premier Customer Services Description.
*
* DEMO POC - "AS IS"
*/

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
