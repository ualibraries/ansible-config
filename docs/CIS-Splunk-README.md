This is the README for Isaiah's new feature branch.

There are 3 major pieces to this repo: Splunk UF installs without _common
                                       Splunk UF updates (again without _common)
                                       CIS Centos7 server hardening

Splunk UF installs without _common:
This new feature contains the ability to point Ansible at existing 
servers to install Splunk on machines that are not currently under
Ansible control. This enabels us to get data from essential servers
without running the common role against them.

Splunk UF updates (again without _common):
This branch also contains the ability to safely update the splunk 
uniniversal forwarders. To keep up to date, the vars.yml will
have to change to update the new splunk release. Both splunk-update
and splunk-forwarder use the splunk-forwarder host group and there
for also use the same vars.yml file. The _common groups vars.yml
will also have to be updated for new forwarders install that way.

CIS Centos7 server hardening:
This new feature also contain the CIS server hardening under the
_ comman role that will break everything on servers who do not 
have the proper directories partitioned. This playbook will mount 
these directories with the proper permissions. It will also take 
care up updating  all kernal and non-kernal updates. Kernal updates 
can be set to true if you want to update the kernal. This playbook
also set up a base iptables confit for IPv4 and IPv6. After these 
firewall rules are set up you can decide to install firewalld to 
make ad-hoc changes in the future. Lastly this book also contains 
the ntp server configurations to set up ntp with the UA ntp server.
