#!/bin/sh

##We will install to home directory. no need for root privilege
#if [ $EUID -ne 0 ]; then
#    echo -e "\n*********This script must be run with root privilege*********"
#    echo -e "*******************Sorry! Exiting*************************\n"
#    exit 1
#fi

var=$HOME/bin

mkdir -p $HOME/bin &&
chmod 755 lcget &&
cp lcget $HOME/bin &&
#Adding $HOME/bin to environment variable
if ! echo $PATH | grep -q  ":$var\([/:]\|$\)"; then echo "export PATH=\$PATH:$var" >> ~/.bashrc && . ~/.bashrc ;fi
echo "lcget installed." || {
echo "Failed to install. Abort."; exit 1; }

echo "Installing dependencies..."

#Install jssh (required by lcget)
if [ ! -f $HOME/bin/jssh ];then 
    echo "Installing jssh (ssh wrapper)"
    if git clone https://github.com/neurobin/jssh;then
        cd jssh &&
        chmod 755 jssh &&
        cp jssh $HOME/bin &&
        echo "Installed jssh successfully." || {
        echo "Failed to install jssh. Abort."; exit 1; }
    elif wget https://github.com/neurobin/jssh/release.tar.gz;then
        #try with wget
        tar -xvf jssh-release.tar.gz &&
        cd jssh-release &&
        chmod 755 jssh &&
        cp jssh $HOME/bin &&
        echo "Installed jssh successfully." || {
        echo "Failed to install jssh. Abort."; exit 1; }
    else 
        echo "
        Failed to install jssh. Install it by downloading from
        https://github.com/neurobin/jssh
        To install, just copy the jssh file to $HOME/bin
        and give it execution (755 recommended) permission"
    fi
fi
echo "
    done. 
    ***$HOME/bin was added to PATH environment variable.***
    To populate it run:
    . ~/.bashrc #don't forget the dot (.)
    If ~/.bashrc is not respected, then manually add the $HOME/bin
    to PATH environment variable."

