# Download and setup conda path

cd $HOME

# Download miniconda for python 3.7
condapath=$(which conda)
if  [[ $? != 0 ]]
then 
    echo "Conda not found. Downloading and Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh && sh Miniconda3-py37_4.9.2-Linux-x86_64.sh -u -b -p
    # Add to path
    export PATH=~/miniconda3/bin:$PATH  
else 
    echo "Conda found installed at $condapath"
fi

# Alias command
alias python3=python3.7

cd DE06_devops_pipeline

conda create -n .env --file requirements.txt -y && conda activate 

subscription_name=$(az account show --query name -o tsv)
tenant_id=$(az account show --query tenantId -o tsv)
odl_number=$(az account show --query user.name -o tsv | grep -oP "odl_user_\K\d+")

az webapp up --resource-group "Azuredevops" --name "flask-ml-service${odl_number}" 

#git clone https://github.com/MortalKommit/DE06_devops_pipeline.git && cd $(basename $_ .git)

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


# az vm run-command invoke --resource-group Azuredevops --name agentVM \
#     --command-id RunShellScript --scripts @package_install_script.sh

# download_folder=$(az vm run-command invoke --resource-group Azuredevops --name agentVM --command-id RunShellScript \
#     --scripts "echo \$PWD" --query "value[].message"  | grep -oP "/(.*)/" )

admin_user=$(az vm show --name agentVM --resource-group Azuredevops --show-details --query osProfile.adminUsername -o tsv)
home_folder="/home/$admin_user"
VMPUBLICIP="$(az vm show --name agentVM --resource-group Azuredevops --show-details --query publicIps -o tsv)"

#scp ./package_install_script.sh configure_pylint.sh $admin_user@$VMPUBLICIP:"${download_folder}"

rsync ./package_install_script.sh $admin_user@$VMPUBLICIP:"${home_folder}"

package_log=$(az vm run-command invoke --resource-group Azuredevops --name agentVM --command-id RunShellScript  \
    --scripts "sudo -u $admin_user bash $home_folder/package_install_script.sh" --query "value[].message" | 
    grep -oP "\[stdout\](.*)")

echo -e $package_log > package_install_log.log

echo "Package Installation Complete."

az vm restart --name agentVM --resource-group Azuredevops
# Wait 40 seconds
echo "Waiting for VM to restart..."
sleep 40s

# Read PAT from user

while read -sp "Enter Personal Access Token(PAT) defined in Azure pipelines: " pat; do
    if [ -z $pat ]; then
        break
    fi

# The steps below require prompts to SSH
ssh -o StrictHostKeyChecking=no -tt devopsagent@$VMPUBLICIP  << EOF
    # Download the agent
    curl -O https://vstsagentpackage.azureedge.net/agent/2.210.0/vsts-agent-linux-x64-2.210.0.tar.gz
    # Create the agent
    rm -r myagent; mkdir myagent && cd myagent && \
    tar -zxvf ../vsts-agent-linux-x64-2.210.0.tar.gz && \
    ~/myagent$ ./config.sh -h
    exit
EOF

#scp ./vm_agent_internal_script.sh devopsagent@$VMPUBLICIP:~/