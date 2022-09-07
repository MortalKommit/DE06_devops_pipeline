az vm create --name agentVM --resource-group Azuredevops --size Standard_DS1_v2 \
    --image UbuntuLTS --admin-username  devopsagent --admin-password devopsagent@123 --nsg-rule SSH \
    --public-ip-sku Standard --nic-delete-option delete --os-disk-delete-option delete 

echo "Waiting after VM creation..."

sleep 5s

VMPUBLICIP="$(az vm show --name agentVM --resource-group Azuredevops --show-details --query publicIps -o tsv)"

scp ./package_install_script.sh ./configure_pylint.sh devopsagent@$VMPUBLICIP:~/

ssh -o StrictHostKeyChecking=no -tt devopsagent@$VMPUBLICIP  << EOF
    nohup sh package_install_script.sh &
    exit
EOF

# Wait 50 seconds
echo "Package installation processing.."
sleep 2m

az vm restart --name agentVM --resource-group Azuredevops

# Wait 50 seconds
echo "Waiting for VM to restart..."
sleep 50s

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