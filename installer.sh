#!/bin/bash
# Script for auto installing the udm-iptv package on a Unifi router.
#
# Copyright (C) 2024 Jeroen Zwart.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# Parse arguments and flags
while [[ $# -gt 0 ]]; do
    case $1 in
        (-h) declare -r HOST=$2;;
        (-u) declare -r USER=$2;;
        (-p) declare -r PASSWORD=$2;;
        (--help) showHelp $2;;
        (-*|--*) echo "Invalid option: -$1.";;
        (*) declare FILE=$1;;
    esac
    shift
done

declare -r TMP_DIR=$(mktemp -d)
declare -r OUTPUT_CYAN='\033[0;36m'
declare -r CONFIG=$(<$FILE)

#/
# Execute the script
#/
function execute {
    installDependency
    changeSshConfig
    connect
    cleanUp
    echo "Done"
}

#/
# Install the dependencies
#/
function installDependency {
    echo "Installing dependencies on current host"
    { 
        apt update
        apt install -y sshpass
    } &> /dev/null
}

#/
# Change the SSH config for connecting with a Unifi device
#/
function changeSshConfig {
    echo "Changing the SSH config, after backing it up"
    cp /etc/ssh/sshd_config $TMP_DIR/sshd_config
    sed -i '/^#PasswordAuthentication/s/#//' /etc/ssh/sshd_config
    sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
    restartSshd
}

#/
# Connect to the Unifi device
#/
function connect {
    echo "Trying to connect to given Unifi device"
    declare -x STATUS=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $USER@$HOST echo OK 2>&1)
    if [[ $STATUS == *"Permission denied"* ]] ; then
        echo -e "Permission denied to \`$HOST\` with user \`$USER\`"
        exit 1
    elif [[ $STATUS != OK ]] ; then
        echo -e "Failed to connect! Something went wrong; $STATUS"
        exit 1
    fi

    echo "Executing following commands on host \`$HOST\`"
    echo -e "${OUTPUT_CYAN}"
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USER@$HOST bash << END
        $(declare -f configureUdmIptv);
        $(declare -f installUdmIptv);
        $(declare -f restartUdmIptv);
        configureUdmIptv '$CONFIG';
        installUdmIptv;
        restartUdmIptv;
END
    echo -e "\033[0m"
}

#/
# Overwrite the conf of udm-iptv
#/
function configureUdmIptv {
    echo "Writing the configuration to '/etc/udm-iptv.conf', after backing it up"
    cp /etc/udm-iptv.conf /etc/udm-iptv.conf.$(date +%Y%m%d%H%M%S).backup
    echo -e "$1" > /etc/udm-iptv.conf
}

#/
# Install the udm-iptv package
#/
function installUdmIptv {
    echo "Installing udm-iptv"
    DEBIAN_FRONTEND=noninteractive sh -c "$(curl https://raw.githubusercontent.com/fabianishere/udm-iptv/master/install.sh -sSf)" &> /dev/null
    echo "Succesful installed"
}

#/
# Restart the service of udm-iptv
#/
function restartUdmIptv {
    echo "Restarting the udm-iptv service"
    systemctl restart udm-iptv
}

#/
# Restart the service of sshd
#/
function restartSshd {
    echo "Restarting the sshd service"
    systemctl restart sshd
}

#/
# Clean up the mess
#/
function cleanUp {
    echo "Reverting the orginal SSH config"
    mv -f $TMP_DIR/sshd_config /etc/ssh/sshd_config
    restartSshd
    echo "Cleaning up"
    rm -rf $TMP_DIR
    apt remove -y sshpass &> /dev/null
}

#/
# Show the help for this script.
#/
function showHelp {
    echo "Script for auto installing the udm-iptv package on a Unifi router"
    echo
    echo "Usage: $0 [options] {profile}"
    echo
    echo "profile   The path of the profile file for udm-iptv" 
    echo
    echo "Options:"
    echo "-h        The host to make a SSH connection to."
    echo "-u        Username setted in Unifi for the SSH connection."
    echo "-p        Password setted in Unifi for the SSH connection."
    echo "--help    This helper"
    cat << EOF
Options:
-h|--help   Print this help.

Arguments:
command     The command to show.     
EOF
}

execute