#!/usr/bin/env bash

PORT=8000
echo "Port: $PORT"

# Check if running inside docker or on host machine
if grep -q docker /proc/1/cgroup; then 
   echo "Running inside docker" 
   PORT=80
else
   echo "Running webapp on VM/non-container machine"
   PORT=5000
   exit
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
     -X POST http://localhost:$PORT/predict
