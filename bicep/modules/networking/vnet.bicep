param location string
param suffix string

var vnetAddressCIDR = '10.0.0.0/16'
var webAppSubnetCIDR = '10.0.1.0/24'
var peSubnetCIDR = '10.0.2.0/24'

resource nsgWebapp 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-webapp'
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
    ]
  }
}

output subnetDelegationId string = vnet.properties.subnets[0].id
