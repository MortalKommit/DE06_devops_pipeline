# Download and setup conda path
# Miniconda for python 3.7
wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh && sh Miniconda3-py37_4.9.2-Linux-x86_64.sh -u -b -p
export PATH=~/miniconda3/bin:$PATH

git clone https://github.com/MortalKommit/DE06_devops_pipeline.git && cd $(basename $_ .git)

az vm create --name agentVM --resource-group Azuredevops --size Standard_DS1_v2 \
    --image UbuntuLTS --admin-username  devopsagent --admin-password devopsagent@123 --nsg-rule SSH \
    --public-ip-sku Standard --nic-delete-option delete --os-disk-delete-option delete 
# Only for dev/test - prefer NSG rule below
az vm open-port --resource-group Azuredevops --name agentVM --port 443

# az network nsg rule create \
#     --resource-group Azuredevops \
#     --nsg-name myNetworkSecurityGroup \
#     --name myNetworkSecurityGroupRule \
#     --protocol tcp \
#     --priority 1000 \
#     --destination-port-range 443

az vm run-command invoke --resource-group Azuredevops --name agentVM \
    --command-id RunShellScript --scripts @package_install_script.sh

# download_folder=$(az vm run-command invoke --resource-group Azuredevops --name agentVM --command-id RunShellScript \
#     --scripts "echo \$PWD" --query "value[].message"  | grep -oP "/(.*)/" )

admin_user=$(az vm show --name agentVM --resource-group Azuredevops --show-details --query osProfile.adminUsername -o tsv)
home_folder="/home/$admin_user"
VMPUBLICIP="$(az vm show --name agentVM --resource-group Azuredevops --show-details --query publicIps -o tsv)"

#scp ./package_install_script.sh configure_pylint.sh $admin_user@$VMPUBLICIP:"${download_folder}"

rsync ./package_install_script.sh configure_pylint.sh $admin_user@$VMPUBLICIP:"${home_folder}"

package_log=$(az vm run-command invoke --resource-group Azuredevops --name agentVM --command-id RunShellScript  \
    --scripts "sudo -u $admin_user bash $home_folder/package_install_script.sh" --query "value[].message" | 
    grep -oP "\[stdout\](.*)")

echo -e $package_log > package_install_log.log

az vm restart --name agentVM --resource-group Azuredevops

# Wait 40 seconds
echo "Waiting for VM to restart..."
sleep 40s

# The steps below require prompts
ssh -o StrictHostKeyChecking=no -tt devopsagent@$VMPUBLICIP  << EOF
    # Download the agent
    curl -O https://vstsagentpackage.azureedge.net/agent/2.210.0/vsts-agent-linux-x64-2.210.0.tar.gz
    # Create the agent
    mkdir myagent && cd myagent && \
    tar -zxvf ../vsts-agent-linux-x64-2.210.0.tar.gz && \
    exit
EOF

#scp ./vm_agent_internal_script.sh devopsagent@$VMPUBLICIP:~/