// Execute this main file to configure ASGs and NSGs for a given application

// Parameters
@description('Azure region used for the deployment resources.')
param location string = resourceGroup().location

//I had to add this, because the current naming doesn't seem to match Azure's Region IDs in all cases
@description('Azure region code used in naming convention')
param regionName string = 'usc'

@description('Business Unit Name (No Spaces)')
param businessUnitName string = 'MyBU'

@description('Application Name (No Spaces)')
param applicationName string = 'MyApplication'

@description('4 Digit Application Code')
param applicationCode string = 'MYAP'

@description('Environment (dev, prod, qa)')
param environment string = 'dev'

@description('Azure Bastion Subnet CIDR')
param bastionSubnet string = '10.x.y.0/24'

@description('Active Directory Subnet CIDR')
param activeDirectorySubnet string = '10.x.y.0/24'

@description('Monitoring Subnet CIDR')
param monitoringSubnet string = '10.x.y.0/24'

  //I added these override switches just in case the naming convention for existing resources
  //don't follow the standard.
@description('Override Subscription Name?')
param overrideSubscription bool = false

@description('Subscription Name.  Set the appropriate BU & Environment')
param overrideSubscriptionName string = 'sub-{bu}-{env}'

@description('Override Resource Group Name?')
param overrideResourceGroup bool = false

@description('Resource Group Name.  Set the appropriate BU, Application, Region Code & Environment')
param overrideResourceGroupName string = 'rg-{application}-{regionCode}-{env}'

@description('Override vNet Name?')
param overrideVnet bool = false

@description('vNet Name.  Set the appropriate BU, Region Code & Environment')
param overrideVnetName string = 'vnet-{bu}-{regionCode}-{env}'

@description('Override subnet Name?')
param overrideSubnet bool = false

@description('Subnet Name.  Set the appropriate BU, Application, Region Code & Environment')
param overrideSubnetName string = 'snet-{application}-{regionCode}-{env}'

@description('Set of tags to apply to all resources.')
param tags object = {}

// Variables
var uniqueSuffix = '${regionName}-${environment}'
var subscriptionName = 'sub-${businessUnitName}-${environment}'
var vnetName= 'vnet-${businessUnitName}-${regionName}-${environment}'
var resourceGroupName= 'rg-${applicationName}-${regionName}-${environment}'
var subnetName= 'snet-${applicationName}-${regionName}-${environment}'
var nsgName = 'nsg-${applicationName}-${regionName}-${environment}'
var applicationId = toLower(applicationCode)

//Modules
module setAsgByFunction 'modules/asg.bicep' = { 
  name: 'asg-${applicationName}-${environment}-deployment'
  params: {
    location: location
    applicationId: applicationId
    environment: environment
  }
}

module scoringNsg 'modules/nsg.bicep' = { 
  name: 'nsg-${name}-scoring-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags 
    nsgName: 'nsg-${name}-scoring-${uniqueSuffix}'
  }
}
