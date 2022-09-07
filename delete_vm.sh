# Uncomment script below to delete resources

vmNIC=$(az vm nic list --resource-group Azuredevops --vm-name agentVM --query [].id -o tsv)

publicIPID=$(az network nic show --ids $vmNIC --query "ipConfigurations[].publicIpAddress.id" -o tsv)

nsgID=$(az network nic show --ids $vmNIC --query "networkSecurityGroup.id" -o tsv)

vnetID=$(az network nic show --ids $vmNIC --query "ipConfigurations[].subnet.id" -o tsv)

az vm delete --resource-group Azuredevops --name agentVM -y
az network nsg delete --ids "$nsgID"
az network public-ip delete --ids "$publicIPID"
az network vnet delete --ids "$vnetID"
