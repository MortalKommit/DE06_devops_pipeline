#!/bin/bash
shopt -s expand_aliases
source ~/.bash_aliases
source ~/.bashrc

pip install pylint
sudo apt-get install python3.7-distutils
sudo apt-get -y install zip
which pylint