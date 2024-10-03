#!/bin/bash
az vm encryption enable --resource-group "CF-Workload-Demo-RG"\
 --name "DosDbSrv-Demo-VM" --disk-encryption-keyvault "CF-System-KeyVault"\
 --volume-type All

az vm encryption enable --resource-group "CF-Workload-Demo-RG"\
 --name "WebSrv-Demo-VM" --disk-encryption-keyvault "CF-System-KeyVault"\
 --volume-type All

az vm encryption enable --resource-group "CF-Workload-Demo-RG"\
 --name "WSDC16-Bastion" --disk-encryption-keyvault "CF-System-KeyVault"\
 --volume-type All

# Status
az vm encryption show --resource-group "CF-Workload-Demo-RG"\
 --name "WebSrv-Demo-VM" 