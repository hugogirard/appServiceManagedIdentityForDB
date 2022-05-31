param location string
param suffix string
param webAppDelegationSubnetId string



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

resource webApp1 'Microsoft.Web/sites@2020-06-01' = {
  name: 'webapp-${suffix}'
  location: location  
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      appSettings: [
        
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
