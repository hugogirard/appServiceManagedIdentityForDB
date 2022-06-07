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
