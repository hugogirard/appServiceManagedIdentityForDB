param location string

var suffix = uniqueString(resourceGroup().id)

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
  }
}
