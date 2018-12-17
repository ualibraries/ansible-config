#!/bin/bash 

# file: roles/_secured/files/usr_local_bin_ubuntu_aide.sh

# This file will run an AIDE check, then it will update the new database  
# and copy it to the baseline database. 
aide -c /etc/aide/aide.conf --check 
aide -c /etc/aide/aide.conf --update 
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
