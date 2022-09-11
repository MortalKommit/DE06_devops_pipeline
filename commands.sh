#!/usr/bin/env bash
# Run script only in home directory
shopt -s expand_aliases

current_dir=$PWD
if [[ $PWD = $HOME ]] 
then
    echo "Script running in Home directory" 
else
    echo "Switching to home before running script"
    cd $HOME
fi
# Download miniconda for python 3.7


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
# Change back to project directory
cd $current_dir

# Add to path
#export PATH=~/miniconda3/bin:\$PATH


if  cat ~/.bash_aliases |  grep -soP "PATH=~/.*conda.*"
then
    touch ~/.bash_aliases
    echo 'PATH=~/miniconda3/bin:$PATH' >> ~/.bash_aliases
fi

# Alias python3 command
if grep -oP "alias python3=python3.7" ~/.bashrc
then 
    echo "Python alias present in bashrc"
else 
    echo "alias python3=python3.7" >> ~/.bashrc
fi

# Alias python3 command
if grep -oP "alias python3=python3.7" ~/.bash_aliases
then 
    echo "Python alias present in bash_aliases"
else 
    touch ~/.bash_aliases
    echo "alias python3=python3.7" >> ~/.bash_aliases
fi

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
    touch ~/.bash_aliases
    echo "alias pylint='python3.7 -m pylint'" >> ~/.bash_aliases
fi

. ~/.bashrc
. ~/.bash_aliases

odl_number=$(az account show --query user.name -o tsv | grep -oP "odl_user_\K\d+")

make all && \
az webapp up --resource-group "Azuredevops" --name "flask-ml-service${odl_number}" 