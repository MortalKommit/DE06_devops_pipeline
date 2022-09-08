#!/usr/bin/env bash

PORT=443
echo "Port: $PORT"

odl_number=$(az account show --query user.name -o tsv | grep -oP "odl_user_\K\d+")

apphostname=$(az webapp show  --resource-group Azuredevops --name  flask-ml-service${odl_number} \
            --query "defaultHostName" -o tsv)
webappstate=$(az webapp show  --resource-group Azuredevops --name  flask-ml-service${odl_number} \
            --query "state" -o tsv)

if ! [[ ( -n $apphostname ) || ( -n $webappstate ) || ! ( $webappstate -eq "Running") ]]
then 
   echo "Webapp service not started. Attempting to start service..."
   az webapp up --resource-group "Azuredevops" --name "flask-ml-service${odl_number}" 
fi

# POST method predict
curl -d '{
   "CHAS":{
      "0":0
   },
   "RM":{
      "0":6.575
   },
   "TAX":{
      "0":296.0
   },
   "PTRATIO":{
      "0":15.3
   },
   "B":{
      "0":396.9
   },
   "LSTAT":{
      "0":4.98
   }
}'\
     -H "Content-Type: application/json" \
     -X POST https://$apphostname:$PORT/predict 
     # Application name set via variables