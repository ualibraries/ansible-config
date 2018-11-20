#!/bin/bash 

# file: roles/_secured/files/usr_local_bin_aide.sh

# This file will run an AIDE check, then it will update the new database  
# and copy it to the baseline database. 
aide --check 
aide --update 
cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz