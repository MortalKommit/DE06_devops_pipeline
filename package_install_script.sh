#!/bin/bash
shopt -s expand_aliases

sudo snap install docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt-get update
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt install -y python3.7 
sudo apt-get install -y python3.7-venv
sudo apt-get install -y python3-pip 

python3.7 --version



# Alias python3 command
if grep -oP "alias python3=python3.7" ~/.bashrc
then 
    echo "python3 alias present in bashrc"
else 
    echo "alias python3=python3.7" >> ~/.bashrc
fi

# Alias python3 command
if grep -oP "alias python3=python3.7" ~/.bash_aliases
then 
    echo "python3 alias present in bash_aliases"
else 
    touch ~/.bash_aliases
    echo "alias python3=python3.7" >> ~/.bash_aliases
fi

# Alias pip command
if grep -oP "alias pip='python3.7 -m pip'" ~/.bashrc
then 
    echo "pip alias present in bashrc"
else 
    echo "alias pip='python3.7 -m pip'" >> ~/.bashrc
fi

# Alias pip command
if grep -oP "alias pip='python3.7 -m pip'" ~/.bash_aliases
then 
    echo "pip alias present in bash_aliases"
else 
    touch ~/.bash_aliases
    echo "alias pip='python3.7 -m pip'" >> ~/.bash_aliases
fi

# Alias pylint command
if grep -oP "alias pylint='python3.7 -m pylint'" ~/.bashrc
then 
    echo "pylint alias present in bashrc"
else 
    touch ~/.bash_aliases
    echo "alias pylint='python3.7 -m pylint'" >> ~/.bashrc
fi

if grep -oP "alias pylint='python3.7 -m pylint'" ~/.bash_aliases
then 
    echo "pylint alias present in bash_aliases"
else 
    touch ~/.bash_aliases
    echo "alias pylint='python3.7 -m pylint'" >> ~/.bash_aliases
fi

source ~/.bash_aliases
source ~/.bashrc

# Install pylint
sudo apt-get install python3.7-distutils
sudo apt-get -y install zip
python3.7 -m pip install pylint
#echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
source ~/.bash_aliases

which pylint
pip --version 

