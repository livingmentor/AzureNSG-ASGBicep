
# Azure Application Deployment - Bicep Files

## Overview
This collection of Bicep files facilitates the setup and configuration of Azure Application Security Groups (ASGs) and Network Security Groups (NSGs) for a given application in Azure. The main file (`main.bicep`) integrates various components and should be used for deployment.  Additionally, a file named azuredeploy.json has been included that was created from the included bicep files that can be deployed with the following link.  

[Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Flivingmentor%2FAzureNSG-ASGBicep%2Fazuredeploy.json)

The architecture of the NSGs & ASGs created from this collection assumes one NSG per subnet, and one subnet per application.  The intention is to create a baseline layer 4 security configuration that only allows intra-application communication.  However, the script also assumes some front end components to be reachable from all internal networks.  For example, webservers allow 443 from the "VirtualNetwork" tag. Active Directory Servers allow the set ports to be allowed from  the "VirtualNetwork" tag as well.  Additional inter-subnet or external access will require further configuration.  

Though there can be a many-to-many relationship between ASGs and NICs, the intention is for a 1:Many, ASG:NIC mapping. 

NSGs will have rules that allow source ASGs to Destination NSGs.  However, the port ranges are configures as a parameter that maps to the servers function.  For example, a Web Server would be assigned the Web Server ASG, specific to a given application, that allows other NICs assigned a different ASG within the same application.  The defaut destination port ranges are configured as a parameter.  However, the defaults are not meant to be exhaustive and will likely require additional configuration on an application-by-application basis.  As this collection continues to evolve, the default ports may change.

This collection is currently untested.  Use at your own risk.

## Files Description
- `main.bicep`: The primary script for deploying the entire configuration. It integrates other Bicep files and sets up the necessary Azure resources.
- `nsg.bicep`: Configures Network Security Groups (NSGs) in relation to different types of ASGs.
- `assignNsgToSubnet.bicep`: Assigns a specific NSG to a subnet within a Virtual Network.
- `asg.bicep`: Defines various Azure Application Security Groups based on the application environment.

## Parameters Description
### main.bicep
- `location`: Azure region for deploying resources.
- `regionName`: Region code used in current naming convention.  This field assumes that current naming convention doesn't align with Azure Region IDs.
- `businessUnitName`: Name of the business unit, without spaces.
- `applicationName`: Name of the application, without spaces.
- `applicationCode`: A 4-digit code representing the application.
- `environment`: Deployment environment (e.g., dev, prod, qa).
- `bastionSubnet`: CIDR for the Azure Bastion Subnet.
- TCP and UDP port range Identifiers: Used to describe the ports used within various server function types.

### nsg.bicep
- Shares several parameters with `main.bicep` such as `location`, `applicationName`, `environment`, and `bastionSubnet`.
- `tags`: Set of tags to apply to all resources.
- ASG-related IDs: Parameters for various ASGs like application server, build server, etc.

### assignNsgToSubnet.bicep
- `nsgId`: Resource ID of the existing NSG.
- `vnetName`: Name of the existing Virtual Network.
- `subnetName`: Name of the existing Subnet.

### asg.bicep
- `location`: Azure region for deploying ASGs.
- `applicationId`: A unique identifier for the application.
- `environment`: Deployment environment (e.g., dev, prod, qa).

## Usage
1. Update the parameters in `main.bicep` as per your deployment requirements.
2. Ensure all dependencies and prerequisites are met before deployment.
3. Execute the `main.bicep` file to deploy the configurations.

OR*

1. [Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Flivingmentor%2FAzureNSG-ASGBicep%2Fazuredeploy.json)
2. Update the fields within the template
3. Deploy the template

*to use the ARM template after updating the bicep files requires the use of 
```az bicep build --file  main.bicep --outfile azuredeploy.json```
to update the azuredeploy.json file

## Prerequisites
- Required permissions in Azure for resource creation and management.
- Parameter values should align with your Azure environment and naming conventions.

## Dependencies
- The `main.bicep` file integrates and depends on `nsg.bicep`, `assignNsgToSubnet.bicep`, and `asg.bicep`. Ensure these files are in the same directory.
