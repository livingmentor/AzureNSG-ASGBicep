@description('Azure region used for the deployment resources.')
param location string = resourceGroup().location

@description('4 Digit Application ID')
param applicationId string = 'myap'

@description('Environment (dev, prod, qa)')
param environment string = 'dev'

resource mainApplicationAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-main-${environment}'
  location: location
}

resource applicationServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-app-${environment}'
  location: location
}

resource buildServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-bld-${environment}'
  location: location
}

resource cachingServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-csh-${environment}'
  location: location
}

resource dataWarehouseAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-dwh-${environment}'
  location: location
}

resource databaseAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-dbx-${environment}'
  location: location
}

resource developmentServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-dev-${environment}'
  location: location
}

resource domainControllerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-dcx-${environment}'
  location: location
}

resource ftpFileServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-ftp-${environment}'
  location: location
}

resource objectFileServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-obj-${environment}'
  location: location
}

resource scpFileServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-scp-${environment}'
  location: location
}

resource smbFileServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-fil-${environment}'
  location: location
}

resource jumpServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-jmp-${environment}'
  location: location
}

resource loggingServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-log-${environment}'
  location: location
}

resource printServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-prt-${environment}'
  location: location
}

resource proxyServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-prx-${environment}'
  location: location
}

resource webServerAsg 'Microsoft.Network/applicationSecurityGroups@2020-11-01' = {
  name: 'asg-${applicationId}-web-${environment}'
  location: location
}

output mainApplicationAsgId string = mainApplicationAsg.id
output applicationServerAsgId string = applicationServerAsg.id
output buildServerAsgId string = buildServerAsg.id
output cachingServerAsgId string = cachingServerAsg.id
output dataWarehouseAsgId string = dataWarehouseAsg.id
output databaseAsgId string = databaseAsg.id
output developmentServerAsgId string = developmentServerAsg.id
output domainControllerServerAsgId string = domainControllerAsg.id
output ftpFileServerAsgId string = ftpFileServerAsg.id
output objFileServerAsgId string = objectFileServerAsg.id
output scpFileServerAsgId string = scpFileServerAsg.id
output smbFileServerAsgId string = smbFileServerAsg.id
output jumpServerAsgId string = jumpServerAsg.id
output loggingServerAsgId string = loggingServerAsg.id
output printServerAsgId string = printServerAsg.id
output proxyServerAsgId string = proxyServerAsg.id
output webServerAsgId string = webServerAsg.id

