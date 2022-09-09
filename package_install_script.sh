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



# Alias pip command
if grep -oP "alias pip='python3.7 -m pip'" ~/.bashrc
then 
    echo "Pip alias present in bash_aliases"
else 
    echo "alias pip='python3.7 -m pip'" >> ~/.bashrc
fi

# Alias pip command
if grep -oP "alias pip='python3.7 -m pylint'" ~/.bashrc
then 
    echo "Pylint alias present in bashrc"
else 
    echo "alias pip='python3.7 -m pylint'" >> ~/.bashrc
fi

# Alias pylint command
if grep -oP "alias pylint='python3.7 -m pylint'" ~/.bash_aliases
then 
    echo "Pylint alias present in bash_aliases"
else 
    echo "alias pylint='python3.7 -m pylint'" >> ~/.bash_aliases
fi

source ~/.bash_aliases
source ~/.bashrc

# Install pylint
sudo apt-get install python3.7-distutils
sudo apt-get -y install zip
python3.7 -m pip install pylint
#echo 'PATH=~/.local/bin:$PATH' >> ~/.bashrc
source ~./bashrc
which pylint
pip --version 

