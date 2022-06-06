param webappname string
param vaultname string
param todoSecret string
param orderSecret string

resource web 'Microsoft.Web/sites@2020-06-01' existing = {
  name: webappname
}

resource todoSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  parent: web
  properties: {
    TodoCnxString: '@Microsoft.KeyVault(VaultName=${vaultname};SecretName=${todoSecret})'
    OrderCnxString: '@Microsoft.KeyVault(VaultName=${vaultname};SecretName=${orderSecret})'
  }
}
