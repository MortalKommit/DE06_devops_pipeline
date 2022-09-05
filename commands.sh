# Download miniconda for python 3.7
condapath=$(which conda)
if  [[ $? != 0 ]]
then 
    echo "Conda not found"
else echo $condapath
fi
#wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh && sh Miniconda3-py37_4.9.2-Linux-x86_64.sh -u -b -p

# Add to path
export PATH=~/miniconda3/bin:$PATH

# Alias command
alias python3=python3.7

#az webapp up -n flask-ml-service206174