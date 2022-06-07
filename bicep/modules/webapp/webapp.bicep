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
param webAppDelegationSubnetId string
param userAssignedIdentityId object
param appInsightsName string

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'plan-${suffix}'
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'P1v2'
    capacity: 1
  }
  kind: 'app'
}

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: 'webapp-${suffix}'
  location: location  
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: userAssignedIdentityId
  }
  properties: {
    serverFarmId: serverFarm.id    
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }        
      ]
      vnetRouteAllEnabled: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
      netFrameworkVersion: 'v6.0'
      alwaysOn: true      
    }    
    clientAffinityEnabled: false
    httpsOnly: true      
    virtualNetworkSubnetId: webAppDelegationSubnetId  
  }  
}

output systemAssignedIdentity string = webApp.identity.principalId
output webAppname string = webApp.name
