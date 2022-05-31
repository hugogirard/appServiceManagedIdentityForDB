param location string

var suffix = uniqueString(resourceGroup().id)

module identity 'modules/identity/userIdentity.bicep' = {
  name: 'identity'
  params: {
    location: location
    suffix: suffix
  }
}

module vnet 'modules/networking/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location 
    suffix: suffix
  }
}

module web 'modules/webapp/webapp.bicep' = {
  name: 'web'
  params: {
    location: location
    suffix: suffix
    webAppDelegationSubnetId: vnet.outputs.subnetDelegationId
    userAssignedIdentityId: {
      '${identity.outputs.userAssignedIdentityId}': {}
    }
  }
}
