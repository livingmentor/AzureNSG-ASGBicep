@description('Azure region used for the deployment resources.')
param location string = resourceGroup().location

@description('Application Name (No Spaces)')
param applicationName string = 'MyApplication'

@description('Environment (dev, prod, qa)')
param environment string = 'dev'

@description('Azure region code used in naming convention')
param regionName string = 'usc'

@description('Azure Bastion Subnet CIDR')
param bastionSubnet string = '10.16.11.192/26'

//Not needed?
//@description('Application Subnet CIDR')
//param applicationSubnet string = '10.x.y.0/24'

//Not needed?
//@description('Active Directory Subnet CIDR')
//param activeDirectorySubnet string = '10.x.y.0/24'

@description('Monitoring Subnet CIDR')
param monitoringSubnet string = '10.16.3.0/26'

@description('Set of tags to apply to all resources.')
param tags object = {}

//Pass in all of the ASGs
param mainApplicationAsgId string
param applicationServerAsgId string
param buildServerAsgId string
param cachingServerAsgId string
param dataWarehouseAsgId string
param databaseAsgId string
param developmentServerAsgId string
param domainControllerServerAsgId string
param ftpFileServerAsgId string
param objFileServerAsgId string
param scpFileServerAsgId string
param smbFileServerAsgId string
param jumpServerAsgId string
param loggingServerAsgId string
param printServerAsgId string
param proxyServerAsgId string
param webServerAsgId string

param applicationServerDestinationTcpPorts array = []
param buildServerDestinationTcpPorts array = []
param cachingServerDestinationTcpPorts array = []
param dataWarehouseDestinationTcpPorts array = []
param databaseDestinationTcpPorts array = []
param developmentServerDestinationTcpPorts array = []
param domainControllerServerDestinationTcpPorts array = []
param ftpFileServerDestinationTcpPorts array = []
param objFileServerDestinationTcpPorts array = []
param scpFileServerDestinationTcpPorts array = []
param smbFileServerDestinationTcpPorts array = []
param jumpServerDestinationTcpPorts array = []
param loggingServerDestinationTcpPorts array = []
param printServerDestinationTcpPorts array = []
param proxyServerDestinationTcpPorts array = []
param webServerDestinationTcpPorts array = []

param applicationServerDestinationUdpPorts array = []
param buildServerDestinationUdpPorts array = []
param cachingServerDestinationUdpPorts array = []
param dataWarehouseDestinationUdpPorts array = []
param databaseDestinationUdpPorts array = []
param developmentServerDestinationUdpPorts array = []
param domainControllerServerDestinationUdpPorts array = []
param ftpFileServerDestinationUdpPorts array = []
param objFileServerDestinationUdpPorts array = []
param scpFileServerDestinationUdpPorts array = []
param smbFileServerDestinationUdpPorts array = []
param jumpServerDestinationUdpPorts array = []
param loggingServerDestinationUdpPorts array = []
param printServerDestinationUdpPorts array = []
param proxyServerDestinationUdpPorts array = []
param webServerDestinationUdpPorts array = []

//Build the resource
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-${applicationName}-${regionName}-${environment}'
  location: location
  tags: tags
  properties: {
    flushConnection: false
    securityRules: [
      {
        name: 'AllowBastion'
        properties: {
          priority: 110
          access: 'Allow'
          description: 'Allow management traffic (RDP/SSH) from bastion host subnet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '3389', '22'
          ]
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: bastionSubnet
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowMGMT'
        properties: {
          priority: 120
          access: 'Allow'
          description: 'Allow management traffic (RDP/SSH) from designated management subnet(s)'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '3389', '22', '5985'
          ]
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowMonitoring'
        properties: {
          priority: 130
          access: 'Allow'
          description: 'Allow ICMP from Monitoring Subnet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          direction: 'Inbound'
          protocol: 'Icmp'
          sourceAddressPrefix: monitoringSubnet
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowApplicationServerTcp'
        properties: {
          priority: 160
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Application Server Logic TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: applicationServerAsgId }
          ]
          destinationPortRanges: applicationServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowApplicationServerUdp'
        properties: {
          priority: 170
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Application Server Logic UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: applicationServerAsgId }
          ]
          destinationPortRanges: applicationServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBuildServerTcp'
        properties: {
          priority: 180
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Build Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: buildServerAsgId }
          ]
          destinationPortRanges: buildServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBuildServerUdp'
        properties: {
          priority: 190
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Build Server Logic UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: buildServerAsgId }
          ]
          destinationPortRanges: buildServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowCachingServerTcp'
        properties: {
          priority: 1100
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Caching Server Logic TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: cachingServerAsgId }
          ]
          destinationPortRanges: cachingServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowCachingServerUdp'
        properties: {
          priority: 1110
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Caching Server Logic UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: cachingServerAsgId }
          ]
          destinationPortRanges: cachingServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDataWarehouseTcp'
        properties: {
          priority: 1120
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow DataWarehouse TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: dataWarehouseAsgId }
          ]
          destinationPortRanges: dataWarehouseDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDataWarehouseUdp'
        properties: {
          priority: 1130
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow DataWarehouse UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: dataWarehouseAsgId }
          ]
          destinationPortRanges: dataWarehouseDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDatabaseTcp'
        properties: {
          priority: 1140
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Database TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: databaseAsgId }
          ]
          destinationPortRanges: databaseDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDatabaseUdp'
        properties: {
          priority: 1150
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Database UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: databaseAsgId }
          ]
          destinationPortRanges: databaseDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDevelopmentServerTcp'
        properties: {
          priority: 1160
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Development Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: developmentServerAsgId }
          ]
          destinationPortRanges: developmentServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDevelopmentServerUdp'
        properties: {
          priority: 1170
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Development Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: developmentServerAsgId }
          ]
          destinationPortRanges: developmentServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDomainControllerServerTcp'
        properties: {
          priority: 1180
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow DomainController TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: domainControllerServerAsgId }
          ]
          destinationPortRanges: domainControllerServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDomainControllerServerUdp'
        properties: {
          priority: 1190
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow DomainControllerServer UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: domainControllerServerAsgId }
          ]
          destinationPortRanges: domainControllerServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowFtpFileServerTcp'
        properties: {
          priority: 1200
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow FTP TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: ftpFileServerAsgId }
          ]
          destinationPortRanges: ftpFileServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowFtpFileServerUdp'
        properties: {
          priority: 1210
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow ftpFileServer UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: ftpFileServerAsgId }
          ]
          destinationPortRanges: ftpFileServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowObjFileServerTcp'
        properties: {
          priority: 1220
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Object File Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: objFileServerAsgId }
          ]
          destinationPortRanges: objFileServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowObjFileServerUdp'
        properties: {
          priority: 1230
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow objFileServer UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: objFileServerAsgId }
          ]
          destinationPortRanges: objFileServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowScpFileServerTcp'
        properties: {
          priority: 1240
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow SCP (SSH, aka SFTP) File Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: scpFileServerAsgId }
          ]
          destinationPortRanges: scpFileServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowScpFileServerUdp'
        properties: {
          priority: 1250
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow SCP (SSH, aka SFTP) File Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: scpFileServerAsgId }
          ]
          destinationPortRanges: scpFileServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSmbFileServerTcp'
        properties: {
          priority: 1260
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow SMB File Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: smbFileServerAsgId }
          ]
          destinationPortRanges: smbFileServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSmbFileServerUdp'
        properties: {
          priority: 1270
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow SMB File Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: smbFileServerAsgId }
          ]
          destinationPortRanges: smbFileServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowJumpServerTcp'
        properties: {
          priority: 1280
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Jump Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: jumpServerAsgId }
          ]
          destinationPortRanges: jumpServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowJumpServerUdp'
        properties: {
          priority: 1290
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Jump Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: jumpServerAsgId }
          ]
          destinationPortRanges: jumpServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowLoggingServerTcp'
        properties: {
          priority: 1300
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Logging Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: loggingServerAsgId }
          ]
          destinationPortRanges: loggingServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowLoggingServerUdp'
        properties: {
          priority: 1310
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Logging Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: loggingServerAsgId }
          ]
          destinationPortRanges: loggingServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowPrintServerTcp'
        properties: {
          priority: 1320
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow print Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: printServerAsgId }
          ]
          destinationPortRanges: printServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowPrintServerUdp'
        properties: {
          priority: 1330
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Print Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: printServerAsgId }
          ]
          destinationPortRanges: printServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowProxyServerTcp'
        properties: {
          priority: 1340
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Proxy Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: proxyServerAsgId }
          ]
          destinationPortRanges: proxyServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowProxyServerUdp'
        properties: {
          priority: 1350
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Proxy Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: proxyServerAsgId }
          ]
          destinationPortRanges: proxyServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowWebServerTcp'
        properties: {
          priority: 1360
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Web Server TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: webServerAsgId }
          ]
          destinationPortRanges: webServerDestinationTcpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowWebServerUdp'
        properties: {
          priority: 1370
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Web Server UDP Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: webServerAsgId }
          ]
          destinationPortRanges: webServerDestinationUdpPorts
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowInternalApplicationTraffic'
        properties: {
          priority: 1380
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow Internal Application Traffic'
          protocol: 'Udp'
          destinationApplicationSecurityGroups: [
            { id: mainApplicationAsgId }
          ]
          destinationPortRange: '*'
          sourceApplicationSecurityGroups: [
            { id: mainApplicationAsgId }
          ]
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyEverythingElseInbound'
        properties: {
          priority: 4000
          access: 'Deny'
          description: 'Deny what is not already allowed'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowVnet'
        properties: {
          priority: 115
          access: 'Allow'
          description: 'Allow vnet to vnet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          direction: 'Outbound'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowInternet'
        properties: {
          priority: 125
          access: 'Allow'
          description: 'Allow vnet to Internet (Still passes through Firewall)'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          direction: 'Outbound'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyEverythingElseOutbound'
        properties: {
          priority: 4005
          access: 'Deny'
          description: 'Deny what is not already allowed'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Outbound'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

output nsgId string = nsg.id
