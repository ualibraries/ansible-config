# ualibraries/ansible-config

## Disclaimer.

*WORK IN PROGRESS*

Mike Simpson is to blame for this.

Some day, this will hopefully expand to control some non-trivial proportion of our
inventory and service offerings; starting out small by managing the Open Arizona
service hosts.

Once this stabilizes, you would expect to find the master branch checked out into
ansible1.library.arizona.edu:/etc/ansible; for now, I've got the "initial_pass"
feature branch checked out on that host instead -- so I'm doing development in
Eclipse et al. on my laptop in the feature branch, pushing it up to Github, then
pulling it down to ansible1 to test.

Yes, non-local feature branches are usually a really bad idea. :)

-mgs, 6/20/2018

## Putting a service under Ansible management.

### Establish DNS entries for service hosts.

fill out the spreadsheet in Box

add A/PTR entries on plutarch

### Add service configuration to Ansible.

pick a service tag

add hosts to inventory files under a group named by the service tag

add a group subdirectory under group_vars, again using the service tag, with vars and vault files

add hosts subdirectories under host_vars, with vars and vault files

add a role subdirectory under roles, using the service tag, and stubbing out files, handlers, tasks, templates

create a "site_[service].yml" file

add an import to site.yml
