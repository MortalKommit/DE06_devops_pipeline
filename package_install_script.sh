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

echo 'alias pip=pip3' >> ~/.bashrc
echo 'alias pip=pip3' >> ~/.bash_aliases
source ~/.bash_aliases
source ~/.bashrc

# Install pylint
sudo apt-get install python3.7-distutils
sudo apt-get -y install zip
python3.7 -m pip install pylint
echo 'PATH=~/.local/bin:$PATH' >> ~/.bashrc
which pylint
#pip --version 

