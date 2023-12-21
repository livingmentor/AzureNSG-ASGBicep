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

//Not Needed?
//@description('Active Directory Subnet CIDR')
//param activeDirectorySubnet string = '10.x.y.0/24'

@description('Monitoring Subnet CIDR')
param monitoringSubnet string = '10.x.y.0/24'

@description('Application Server Destination TCP Ports')
param applicationServerDestinationTcpPorts array = ['1024-49151']
@description('Application Server Destination UDP Ports')
param applicationServerDestinationUdpPorts array = ['1024-49151']

@description('Build Server Destination TCP Ports')
param buildServerDestinationTcpPorts array = []
@description('Build Server Destination UDP Ports')
param buildServerDestinationUdpPorts array = []

@description('Caching Server Destination TCP Ports')
param cachingServerDestinationTcpPorts array = ['6379-6380', '9443', '8080', '8000-8001']
@description('Caching Server Destination UDP Ports')
param cachingServerDestinationUdpPorts array = ['53', '5353']

@description('DataWarehouse Destination TCP Ports')
param dataWarehouseDestinationTcpPorts array = ['1433-1434']
@description('DataWarehouse Destination UDP Ports')
param dataWarehouseDestinationUdpPorts array = ['1434']

@description('Database Destination TCP Ports')
param databaseDestinationTcpPorts array = ['135', '139', '443', '445', '1433-1434', '2383', '2393-2394', '2725', '3882', '4022', '5022', '7022', '49152-65535']
@description('DatabaseDestination UDP Ports')
param databaseDestinationUdpPorts array = ['135', '138', '445', '500', '1434', '2382', '3343', '4500', '5000-5099', '8011-8031']

@description('Development Server Destination TCP Ports')
param developmentServerDestinationTcpPorts array = []
@description('Development Server Destination UDP Ports')
param developmentServerDestinationUdpPorts array = []

//TODO: Add Dynamic RPC port range or select a static port based on AD configuration
@description('Domain Controller Destination TCP Ports')
param domainControllerServerDestinationTcpPorts array = ['53', '88', '135', '389', '445', '636', '1723', '3268-3269']
@description('Domain Controller Destination UDP Ports')
param domainControllerServerDestinationUdpPorts array = ['53', '88', '389']

//TODO: Determine how to enable Active FTP
@description('FTP File Server Destination TCP Ports')
param ftpFileServerDestinationTcpPorts array = ['21']
@description('FTP File Server Destination UDP Ports')
param ftpFileServerDestinationUdpPorts array = []

//Add 80 if required/allowed
@description('Object File Server (blobs, for example) Destination TCP Ports')
param objFileServerDestinationTcpPorts array = ['443']
@description('Object File Server (blobs, for example) Destination UDP Ports')
param objFileServerDestinationUdpPorts array = []


@description('SCP (SSH/SFTP) File Server Destination TCP Ports')
param scpFileServerDestinationTcpPorts array = ['22']
@description('SCP (SSH/SFTP) File Server Destination UDP Ports')
param scpFileServerDestinationUdpPorts array = []

@description('SMB/SAMBA/Windows File Server Destination TCP Ports')
param smbFileServerDestinationTcpPorts array = ['139', '445']
@description('SMB/SAMBA/Windows File Server Destination UDP Ports')
param smbFileServerDestinationUdpPorts array = ['137-138']


//Jump Servers shouldn't be used unless absolutely required.  Use Azure bastion instead.
//Additional Configuration is required.  
@description('Jump Server Destination TCP Ports')
param jumpServerDestinationTcpPorts array = []
@description('Jump Server Destination UDP Ports')
param jumpServerDestinationUdpPorts array = []

@description('Logging Server Destination TCP Ports')
param loggingServerDestinationTcpPorts array = ['601']
@description('Logging Server Destination UDP Ports')
param loggingServerDestinationUdpPorts array = ['514']

@description('Print Server Destination TCP Ports')
param printServerDestinationTcpPorts array = ['135', '139', '445', '49152-65535']
@description('Print Server Destination UDP Ports')
param printServerDestinationUdpPorts array = ['137-138']

@description('Proxy Server Destination TCP Ports')
param proxyServerDestinationTcpPorts array = ['22', '80', '443', '1080-1081', '3128', '8080', '8008']
@description('Proxy Server Destination UDP Ports')
param proxyServerDestinationUdpPorts array = []

@description('Web Server Destination TCP Ports')
param webServerDestinationTcpPorts array = ['80', '443']
@description('Web Server Destination UDP Ports')
param webServerDestinationUdpPorts array = []

//I added these override switches just in case the naming convention for existing resources
//don't follow the standard.
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
var vnetName = 'vnet-${businessUnitName}-${regionName}-${environment}'
var subnetName = 'snet-${applicationName}-${regionName}-${environment}'
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

module setNsgByApplication 'modules/nsg.bicep' = { 
  name: '${nsgName}-deployment'
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    regionName: regionName
    bastionSubnet: bastionSubnet
    monitoringSubnet: monitoringSubnet
    tags: tags
    applicationServerAsgId: setAsgByFunction.outputs.applicationServerAsgId
    buildServerAsgId: setAsgByFunction.outputs.buildServerAsgId
    cachingServerAsgId: setAsgByFunction.outputs.cachingServerAsgId
    dataWarehouseAsgId: setAsgByFunction.outputs.dataWarehouseAsgId
    databaseAsgId: setAsgByFunction.outputs.databaseAsgId
    developmentServerAsgId: setAsgByFunction.outputs.developmentServerAsgId
    domainControllerServerAsgId: setAsgByFunction.outputs.domainControllerServerAsgId
    ftpFileServerAsgId: setAsgByFunction.outputs.ftpFileServerAsgId
    objFileServerAsgId: setAsgByFunction.outputs.objFileServerAsgId
    scpFileServerAsgId: setAsgByFunction.outputs.scpFileServerAsgId
    smbFileServerAsgId: setAsgByFunction.outputs.smbFileServerAsgId 
    jumpServerAsgId: setAsgByFunction.outputs.jumpServerAsgId
    loggingServerAsgId: setAsgByFunction.outputs.loggingServerAsgId
    printServerAsgId: setAsgByFunction.outputs.printServerAsgId
    proxyServerAsgId: setAsgByFunction.outputs.proxyServerAsgId
    webServerAsgId: setAsgByFunction.outputs.webServerAsgId
    applicationServerDestinationTcpPorts: applicationServerDestinationTcpPorts
    buildServerDestinationTcpPorts: buildServerDestinationTcpPorts
    cachingServerDestinationTcpPorts: cachingServerDestinationTcpPorts
    dataWarehouseDestinationTcpPorts: dataWarehouseDestinationTcpPorts
    databaseDestinationTcpPorts: databaseDestinationTcpPorts
    developmentServerDestinationTcpPorts: developmentServerDestinationTcpPorts
    domainControllerServerDestinationTcpPorts: domainControllerServerDestinationTcpPorts
    ftpFileServerDestinationTcpPorts: ftpFileServerDestinationTcpPorts
    objFileServerDestinationTcpPorts: objFileServerDestinationTcpPorts
    scpFileServerDestinationTcpPorts: scpFileServerDestinationTcpPorts
    smbFileServerDestinationTcpPorts: smbFileServerDestinationTcpPorts
    jumpServerDestinationTcpPorts: jumpServerDestinationTcpPorts
    loggingServerDestinationTcpPorts: loggingServerDestinationTcpPorts
    printServerDestinationTcpPorts: printServerDestinationTcpPorts
    proxyServerDestinationTcpPorts: proxyServerDestinationTcpPorts
    webServerDestinationTcpPorts: webServerDestinationTcpPorts
    applicationServerDestinationUdpPorts: applicationServerDestinationUdpPorts
    buildServerDestinationUdpPorts: buildServerDestinationUdpPorts
    cachingServerDestinationUdpPorts: cachingServerDestinationUdpPorts
    dataWarehouseDestinationUdpPorts: dataWarehouseDestinationUdpPorts
    databaseDestinationUdpPorts: databaseDestinationUdpPorts
    developmentServerDestinationUdpPorts: developmentServerDestinationUdpPorts
    domainControllerServerDestinationUdpPorts: domainControllerServerDestinationUdpPorts
    ftpFileServerDestinationUdpPorts: ftpFileServerDestinationUdpPorts
    objFileServerDestinationUdpPorts: objFileServerDestinationUdpPorts
    scpFileServerDestinationUdpPorts: scpFileServerDestinationUdpPorts
    smbFileServerDestinationUdpPorts: smbFileServerDestinationUdpPorts
    jumpServerDestinationUdpPorts: jumpServerDestinationUdpPorts
    loggingServerDestinationUdpPorts: loggingServerDestinationUdpPorts
    printServerDestinationUdpPorts: printServerDestinationUdpPorts
    proxyServerDestinationUdpPorts: proxyServerDestinationUdpPorts
    webServerDestinationUdpPorts: webServerDestinationUdpPorts
  }
}

module setSubnetWithNsg 'modules/assignNsgToSubnet.bicep' = {
  name: 'asg-${applicationName}-${environment}-deployment'
  params: {
    nsgId: setNsgByApplication.outputs.nsgId
    vnetName: (overrideVnet) ? overrideVnetName : vnetName
    subnetName: (overrideSubnet) ? overrideSubnetName : subnetName
  }
}
