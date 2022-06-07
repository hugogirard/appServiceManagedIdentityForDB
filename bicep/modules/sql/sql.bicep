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

param privateIpVM string

param vnetName string
param vnetId string

param subnetId string

var serverName = uniqueString('sql', resourceGroup().id)
var todoDB = 'TodoDB'
var orderDB = 'OrderDB'

resource server 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlTodoDB 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: server
  name: todoDB
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource sqlOrderDB 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: server
  name: orderDB
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-sql'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-sql'
        properties: {
          privateLinkServiceId: server.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'global'
  properties: {}
}

resource aRecordVM 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateDnsZoneName.name}/@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateIpVM
      }
    ]
  }
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZoneName
  name: 'link_to_${toLower(vnetName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtEndpointDnsGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZoneName.id
        }
      }
    ]
  }
}

output sqlServerName string = serverName
output todoDbName string = sqlTodoDB.name
output orderDbName string = sqlOrderDB.name

