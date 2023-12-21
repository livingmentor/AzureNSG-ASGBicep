param nsgId string // Resource ID of the existing NSG
param vnetName string // Name of the existing VNet
param subnetName string // Name of the existing Subnet

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: vnet
  name: subnetName
  properties: {
    networkSecurityGroup: {
      id: nsgId
    }
  }
}
