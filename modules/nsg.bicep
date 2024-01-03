@description('Azure region used for the deployment resources.')
param location string = resourceGroup().location

@description('Application Name (No Spaces)')
param applicationName string = 'MyApplication'

@description('Environment (dev, prod, qa)')
param environment string = 'dev'

@description('Azure region code used in naming convention')
param regionName string = 'usc'

@description('Azure Bastion Subnet CIDR')
param bastionSubnet string = '10.x.y.0/24'

//Not needed?
//@description('Application Subnet CIDR')
//param applicationSubnet string = '10.x.y.0/24'

//Not needed?
//@description('Active Directory Subnet CIDR')
//param activeDirectorySubnet string = '10.x.y.0/24'

@description('Monitoring Subnet CIDR')
param monitoringSubnet string = '10.x.y.0/24'

@description('Set of tags to apply to all resources.')
param tags object = {}

//Pass in all of the ASGs
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
        name: 'AllowMonitoring'
        properties: {
          priority: 120
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
        name: 'AllowInternalWeb'
        properties: {
          priority: 130
          access: 'Allow'
          description: 'Allow Web Traffic from "VirtualNetwork"'
          destinationApplicationSecurityGroups: [
            { id: webServerAsgId }
          ]
          destinationPortRange: '443'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowInternalAdTcp'
        properties: {
          priority: 140
          access: 'Allow'
          description: 'Allow AD Traffic from "VirtualNetwork"'
          destinationApplicationSecurityGroups: [
            { id: domainControllerServerAsgId }
          ]
          destinationPortRanges: domainControllerServerDestinationTcpPorts
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
      name: 'AllowInternalAdUdp'
      properties: {
        priority: 150
        access: 'Allow'
        description: 'Allow AD Traffic from "VirtualNetwork"'
        destinationApplicationSecurityGroups: [
          { id: domainControllerServerAsgId }
        ]
        destinationPortRanges: domainControllerServerDestinationUdpPorts
        direction: 'Inbound'
        protocol: 'Tcp'
        sourceAddressPrefix: 'VirtualNetwork'
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
            { id: dataWarehouseAsgId }
          ]
          destinationPortRanges: databaseDestinationTcpPorts
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDomainControllerServerTcp'
        properties: {
          priority: 1180
          access: 'Allow'
          direction: 'Inbound'
          description: 'Allow DataWarehouse TCP Traffic'
          protocol: 'Tcp'
          destinationApplicationSecurityGroups: [
            { id: domainControllerServerAsgId }
          ]
          destinationPortRanges: domainControllerServerDestinationTcpPorts
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
          ]
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
          sourceApplicationSecurityGroups: [
            { id: applicationServerAsgId }
            { id: buildServerAsgId }
            { id: cachingServerAsgId }
            { id: dataWarehouseAsgId }
            { id: databaseAsgId }
            { id: developmentServerAsgId }
            { id: domainControllerServerAsgId }
            { id: ftpFileServerAsgId }
            { id: objFileServerAsgId }
            { id: scpFileServerAsgId }
            { id: smbFileServerAsgId }
            { id: jumpServerAsgId }
            { id: loggingServerAsgId }
            { id: printServerAsgId }
            { id: proxyServerAsgId }
            { id: webServerAsgId }
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
