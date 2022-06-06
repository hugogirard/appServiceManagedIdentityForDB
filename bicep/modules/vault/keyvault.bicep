param location string
param suffix string
param identityWebApp string
param subnetId string
param vnetId string
param vnetName string
param privateIpVM string
param userAssignedIdentityClientId string

param serverName string
param todoDbName string
param orderDbName string

var todoDbCnxString = 'Server=tcp:${serverName}${environment().suffixes.sqlServerHostname};Authentication=Active Directory Managed Identity; User Id=${userAssignedIdentityClientId};Database=${todoDbName}'
var orderDbCnxString = 'Server=tcp:${serverName}${environment().suffixes.sqlServerHostname};Authentication=Active Directory Managed Identity; User Id=${userAssignedIdentityClientId};Database=${orderDbName}'

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: 'vault-${suffix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        
      ]
      virtualNetworkRules: [
        
      ]
    }
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
  location: location
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
  location: 'global'
}


resource aRecordVM 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateDnsZone.name}/@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateIpVM
      }
    ]
  }
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'link_to_${toLower(vnetName)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource dnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  name: '${privateEndpoint.name}/default'
  dependsOn: [
    vault
  ]
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      } 
    ]
  }
}

resource todoDbSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: vault
  name: 'todoDBCnxString'
  properties: {
    value: todoDbCnxString
  }
}


resource orderDbSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: vault
  name: 'orderDBCnxString'
  properties: {
    value: orderDbCnxString
  }
}

resource userAssignedIdentity 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: vault
  name: 'userAssignedIdentity'
  properties: {
    value: userAssignedIdentityClientId
  }
}



output vaultName string = vault.name
output todoSecret string = todoDbSecret.name
output orderSecret string = orderDbSecret.name
output userAssignedIdentitySecret string = userAssignedIdentity.name
