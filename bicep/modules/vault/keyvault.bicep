param location string
param suffix string
param identityWebApp string
param subnetId string
param vnetId string
param vnetName string

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: 'vault-${suffix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: identityWebApp
        permissions: {
            secrets: [
                'all'                      
            ]
        }
    }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'pe-vault'
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-vault'
        properties: {
          privateLinkServiceId: vault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZone.name}/${vnetName}'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource dnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  name: '${privateEndpoint.name}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZone.name
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      } 
    ]
  }
}
