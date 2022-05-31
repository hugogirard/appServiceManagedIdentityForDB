param location string
param suffix string
param identityWebApp string

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
