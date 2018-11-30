#!/bin/bash 

# file: roles/_secured/files/usr_local_bin_check-apt-updates.sh

# This file checks for updates. 
apt list --upgradable > /var/log/updates/updates.log
