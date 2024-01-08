# -*- coding: utf-8 -*-
"""
@author: livingmentor
"""
import argparse
import pandas as pd
import json
import socket

#function to check if a specific port/protocol pair is known
def IsKnownPort(port, protocol):
    try:
        socket.getservbyport(port, protocol)
        return True
    except:
        return False


# Set up the argument parser
parser = argparse.ArgumentParser(description='Process servermap and dependencymap CSV files')
parser.add_argument('-servermap', help='Path to the servermap.csv file')
parser.add_argument('-dependencymap', help='Path to the dependencymap.csv file')
parser.add_argument('-parametertemplate', default='.\parametertemplate.json', help='Path to the parametertemplate.json file')
parser.add_argument('-outfile', default='.\parameter.json', help='Path and file name of the output')

# Parse arguments from the command line
args = parser.parse_args()

# Reference the file paths provided by the user
# If they are empty, prompt the user
serverMapPath = args.servermap
dependencyMapPath = args.dependencymap
parameterTemplatePath = args.parametertemplate


while not serverMapPath:
    serverMapPath = input("Enter path to server map csv file: ")

while not dependencyMapPath:
    dependencyMapPath = input("Enter path to dependency map csv file: ")

# Process the servermap CSV file
serverMapDataFrame = pd.read_csv(serverMapPath, comment='#')
dependencyMapDataFrame = pd.read_csv(dependencyMapPath, comment='#')

# Process JSON Template
with open(parameterTemplatePath, 'r') as file:
    jsonData = json.load(file)

# This type map gets iterated over to classify hosts in the server map 
# to build the TCP and UDP rules to be output in the JSON output file.
typeMap = {
    'application' : 'applicationServerDestination',
    'build' : 'buildServerDestination',
    'cache' : 'cachingServerDestination',
    'datawarehouse' : 'dataWarehouseDestination',
    'database' : 'databaseDestination',
    'development' : 'developmentServerDestination',
    'domaincontroller' : 'domainControllerServerDestination',
    'ftp' : 'ftpFileServerDestination',
    'obj' : 'objFileServerDestination',
    'scp' : 'scpFileServerDestination',
    'smb' : 'smbFileServerDestination',
    'jump' : 'jumpServerDestination',
    'logging' : 'loggingServerDestination',
    'print' : 'printServerDestination',
    'proxy' : 'proxyServerDestination',
    'web' : 'webServerDestination'
}

parameters = {}
#We don't want RDP or WinRM to be allowed from anywhere other than the management/bastion networks.
knownExcludedPorts = [3389, 5985]

# Parse the Map
for k, v in typeMap.items():
    portList = []
    tcpPortList = []
    udpPortList = []

    #Filters the list down to the specific server(s) with a given type
    filteredFrame = serverMapDataFrame[serverMapDataFrame['serverType'] == k]
    servers = filteredFrame['serverName'].unique()
    serverList = servers.tolist()
    for server in serverList:
        filteredFrame = dependencyMapDataFrame[dependencyMapDataFrame['Destination server name'] == server]
        ports = filteredFrame['Destination port'].unique()
        portList.extend(ports.tolist())
    
    # Takes the discovered ports and determines if they should be TCP, UDP, or both.
    for port in portList:
        if port in knownExcludedPorts:
            continue
        isTcp = IsKnownPort(port, "tcp")
        isUdp = IsKnownPort(port, "udp")
        if (isTcp and isUdp) or (not isTcp and not isUdp):
            tcpPortList.append(port)
            udpPortList.append(port)
        elif isTcp and not isUdp:
            tcpPortList.append(port)
        elif not isTcp and isUdp:
            udpPortList.append(port)
    if len(tcpPortList) > 0:
        parameters[v + "TcpPorts"] = {'value': tcpPortList}
    if len(udpPortList) > 0:
        parameters[v + "UdpPorts"] = {'value': udpPortList}

# Takes what we've done and outputs it as a json file to be used in conjunction with the bicep or ARM template.
jsonData['parameters'] = parameters
with open(args.outfile, 'w') as file:
    json.dump(jsonData, file, indent=4)


