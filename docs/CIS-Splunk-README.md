This is the README for isaiahs new feature branch.

This new feature contains the ability to point Ansible at existing 
servers to install Splunk on machines that are not currently under
Ansible control. This enabels us to get data from essential servers
without running the common role on them. 

This new feature also contain the CIS server hardening that will
break everything on servers who do not have the proper directories
partitioned ouit. This book will properly mount these directories
with the proper permissions. It will also take care up updating 
all kernal and non-kernal updates. Kernal updates can be set to 
true if you want to update the kernal. This playbook also set up
a base iptables confit for IPv4 and IPv6. After these firewall
rules are set up you can decide to install firewalld to make 
changes in the future. Lastly this book also contains t he ntp
server configurations to set up ntp with the UA ntp server.

# Running the Splunk playbook. Make sure your target host is in a
# host file (_production) under the stanza [splunk].
#     $ ansible-playbook site_splunk_forwarder.yml --ask-vault-pass \
#                                                  --inventory _production \
#                                                  --limit splunk