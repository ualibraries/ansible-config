#!/bin/bash 

# file: roles/_secured/files/usr_local_bin_check-yum-updates.sh

# This file checks for updates. 
yum check-update > /var/log/updates/updates.log
