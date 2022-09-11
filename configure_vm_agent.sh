#!/bin/bash
# Download and setup conda path

cd $HOME

# Download miniconda for python 3.7
condapath=$(which conda)

if  [[ $? != 0 ]]
then 
    echo "Conda not found. Checking for existing Miniconda download..."
    if (ls | grep -q Miniconda3-py37_4.9.2-Linux-x86_64.sh); then
        echo "Package found, installing..." && \
        sh Miniconda3-py37_4.9.2-Linux-x86_64.sh -u -b -p
    else 
        wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh && sh Miniconda3-py37_4.9.2-Linux-x86_64.sh -u -b -p
    fi

    # Add to path
    export PATH=~/miniconda3/bin:$PATH
    if ! grep -oP 'PATH=~/miniconda3/bin:\$PATH$' ~/.bashrc 
    then 
        echo 'PATH=~/miniconda3/bin:$PATH' >> ~/.bashrc
    fi
else 
    echo "Conda found installed at $condapath"
fi

source ~/.bashrc

cd DE06_devops_pipeline

echo "Configuring environment details..."


subscription_name=$(az account show --query name -o tsv)
tenant_id=$(az account show --query tenantId -o tsv)
odl_number=$(az account show --query user.name -o tsv | grep -oP "odl_user_\K\d+")

# Start webapp
echo "Starting Azure webapp service..."
az webapp up --resource-group "Azuredevops" --name "flask-ml-service${odl_number}" 

#git clone https://github.com/MortalKommit/DE06_devops_pipeline.git && cd $(basename $_ .git)

echo "Webapp Service Started. Creating Virtual Machine for Build Agent"
az vm create --name agentVM --resource-group Azuredevops --size Standard_DS1_v2 \
    --image UbuntuLTS --admin-username  devopsagent --admin-password devopsagent@123 --nsg-rule SSH \
    --public-ip-sku Standard --nic-delete-option delete --os-disk-delete-option delete 

# Open port for invoke command dev/test - prefer NSG rule below
az vm open-port --resource-group Azuredevops --name agentVM --port 443

# Alternative shell script commands to open port
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
echo "Copying scripts to virtual machine..."
# Trap interrupts and exit instead of continuing the loop
trap "echo Exited!; exit;" SIGINT SIGTERM

MAX_RETRIES=5
i=0

# Set the initial return value to failure
false

while [ $? -ne 0 -a $i -lt $MAX_RETRIES ]
do
    sleep 3s;
    i=$(($i+1));
    rsync -avz --progress --partial ./package_install_script.sh $admin_user@$VMPUBLICIP:"${home_folder}"
done

if [ $i -eq $MAX_RETRIES ]
then
    echo "Hit maximum number of retries, giving up."
fi

#rsync ./package_install_script.sh $admin_user@$VMPUBLICIP:"${home_folder}"

package_log=$(az vm run-command invoke --resource-group Azuredevops --name agentVM --command-id RunShellScript  \
    --scripts "sudo -u $admin_user bash $home_folder/package_install_script.sh" --query "value[].message" | 
    grep -oP "\[stdout\](.*)")

echo -e $package_log > package_install_log.log

echo "Package Installation Complete. Restarting VM..."

az vm restart --name agentVM --resource-group Azuredevops
# Wait 40 seconds
echo "Waiting for VM to restart..."
sleep 40s

fullorgname=$(az account show --query user.name -o tsv | grep -oP "\K\w+" | head -1)
devorgname=${fullorgname//_/}

# Read PAT from user
patTOKEN= read -sp "Enter Personal Access Token (PAT):"

while [[ "$patTOKEN" =~ [^a-zA-Z0-9]{30, } || -z "$patTOKEN" ]]
do        
   echo "Enter a valid PAT, which doesn't contain special characters"        
   
   
# Input from user
   read -sp "Input : " patTOKEN
   
#loop until the user enters only alphanumeric characters.
done

     
echo "Use default agent pool name, agent name? [vmAgentPool, vmAgent]"
select yn in "yes" "no"; do
    case $yn in
        yes ) echo "Pool name: 'vmAgentPool' agent: 'vmAgent'"; 
              poolName="vmAgentPool"; agentName="vmAgent"; break;;
        no ) read -p "Enter pool name:" poolName;
             read -p "Enter agent name:" agentName; 
             while [[ -z "$poolName"  || -z "$agentName" ]]
             do        
                echo "Enter valid pool/agent Names"        
                read -p "Enter pool name:" poolName;
                read -p "Enter agent name:" agentName;
             done
             break;;
    esac
done
   
   
# Input from user
   read -p "Input : " patTOKEN
   
#loop until the user enters only alphanumeric characters.
done

# The steps below require prompts to SSH
i=0
MAX_RETRIES=5

until [ "$i" -ge "$MAX_RETRIES" ]
do
{ ssh -o StrictHostKeyChecking=no -tt devopsagent@"$VMPUBLICIP" << EOF
    # Download the agent
    curl -O https://vstsagentpackage.azureedge.net/agent/2.210.0/vsts-agent-linux-x64-2.210.0.tar.gz
    # Create the agent
    rm -r myagent; mkdir myagent && cd myagent && \
    tar -zxvf ../vsts-agent-linux-x64-2.210.0.tar.gz && \
    ./config.sh --unattended --url https://dev.azure.com/$devorgname --auth pat --token $patTOKEN \
        --pool $poolName --agent $agentName --acceptTeeEula
    sudo ./svc.sh install && \
    sudo ./svc.sh start && \
    exit
EOF
} && break
echo "Retrying.. Attempt $i";
sleep 5;
i=$((i+1))
done

echo "Configured VM agent, started build agent service."
#scp ./vm_agent_internal_script.sh devopsagent@$VMPUBLICIP:~/