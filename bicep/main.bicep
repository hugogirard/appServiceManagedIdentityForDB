param location string

@secure()
param administratorLogin string

@secure()
param administratorLoginPassword string

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

module workspace 'modules/workspace/workspace.bicep' = {
  name: 'workspace'
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
    appInsightsName: workspace.outputs.appInsightName
  }
}

module vault 'modules/vault/keyvault.bicep' = {
  name: 'vault'
  params: {
    location: location
    suffix: suffix
    identityWebApp: web.outputs.systemAssignedIdentity
    subnetId: vnet.outputs.subnetPeId
    vnetId: vnet.outputs.vnetId
    vnetName: vnet.outputs.vnetName
    orderDbName: sql.outputs.orderDbName
    serverName: sql.outputs.sqlServerName
    todoDbName: sql.outputs.todoDbName
    privateIpVM: jumpbox.outputs.privateIps
    userAssignedIdentityClientId: identity.outputs.userAssignedIdentityClientId
  }
}

module webSettings 'modules/webapp/settings.bicep' = {
  name: 'webSettings'
  params: {
    todoSecret: vault.outputs.todoSecret
    vaultname: vault.outputs.vaultName
    webappname: web.outputs.webAppname
    orderSecret: vault.outputs.orderSecret    
  }
}

module sql 'modules/sql/sql.bicep' = {
  name: 'sql'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    subnetId: vnet.outputs.subnetPeId
    vnetId: vnet.outputs.vnetId
    vnetName: vnet.outputs.vnetName
    privateIpVM: jumpbox.outputs.privateIps
  }
}

module jumpbox 'modules/jumpbox/jumpbox.bicep' = {
  name: 'jumpbox'
  params: {
    adminPassword: administratorLoginPassword
    adminUsername: administratorLogin
    location: location
    subnetId: vnet.outputs.subnetJumpboxId
  }
}

output sqlServerName string = sql.outputs.sqlServerName
output webappName string = web.outputs.webAppname
