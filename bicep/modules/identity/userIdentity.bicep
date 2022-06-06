param location string
param suffix string

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'user-webapp-${suffix}'
  location: location
}

output userAssignedIdentityId string = msi.id
output userAssignedIdentityClientId string = msi.properties.clientId
