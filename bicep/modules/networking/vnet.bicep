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


param location string
param suffix string

var vnetAddressCIDR = '10.0.0.0/16'
var webAppSubnetCIDR = '10.0.1.0/24'
var peSubnetCIDR = '10.0.2.0/24'
var jumpboxSubnetCIDR = '10.0.3.0/24'

resource nsgWebapp 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-webapp'
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource nsgJumpbox 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-jumpbox'
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-webapp-${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressCIDR
      ]
    }
    subnets: [
      {
        name: 'snet-webapp-delegation'
        properties: {
          addressPrefix: webAppSubnetCIDR
          delegations: [
            {
              name: 'webappdelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }            
          ]
          networkSecurityGroup: {
            id: nsgWebapp.id
          }
        }
      }
      {
        name: 'snet-pe'
        properties: {
          addressPrefix: peSubnetCIDR
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-jumpbox'
        properties: {
          addressPrefix: jumpboxSubnetCIDR
          networkSecurityGroup: {
            id: nsgJumpbox.id
          }
        }
      }      
    ]
  }
}

output subnetDelegationId string = vnet.properties.subnets[0].id
output subnetPeId string = vnet.properties.subnets[1].id
output subnetJumpboxId string = vnet.properties.subnets[2].id
output vnetName string = vnet.name
output vnetId string = vnet.id
