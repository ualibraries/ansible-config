# Notes for build of ansible1.library.arizona.edu.

## Prerequisite steps.

### Local platform.

Apple MacBook Pro (Retina, 15-inch, Mid 2015) w/16 GB RAM, running
macOS Sierra 10.12.6.

Using Emacs 25.3 for an IDE, installed from https://emacsformacosx.com/.

### Establish Github repository for Ansible configuration.

*   In **Github**, created a new repository as:

        Owner: ualibraries
		Repository name: ansible-config
		Description: Ansible configuration for UA Libraries service platforms.
		Visibility: Public
		Initialize this repository with a README: (unchecked)
		Add .gitignore: None
		Add a license: None

    and clicked "Create repository".
	
*   Left the repository empty for the moment.

### Establish DNS entry for Ansible control host.

#### Reserve IP address.

*   In **Box**, navigated to:

        All Files -> TeSS Limited Access -> IP Addresses
		
	and opened "LCU-IPs.xlsx".
	
*   On the "LCU1-Scratch-1 (204)" tab, chose an unused IP address and
    annotated as follows:
	
	    IP Address: 10.130.154.120
		Hostname: ansible1.library.arizona.edu
		Purpose: Ansible control host for LCU1 deployments.
		Notes: mgsimpson, 6/19/2018

#### Configure DNS records.

*   Using **Microsoft Remote Desktop**, connected to:

        plutarch.library.arizona.edu
		
	using my library domain credentials.
	
*   Opened **DNS Manager**, navigated to:

        DNS -> PLUTARCH- > Forward Lookup Zones -> library.arizona.edu
	
*   Right-clicked, chose "New Host (A or AAAA)...", filled in "New Host"
    dialogue as:
	
	    Name: ansible1
		FQDN: ansible1.library.arizona.edu
		IP address: 10.130.154.120
		Create associated pointer (PTR) record: (checked)
		
    and clicked "Add Host".
	
*   Still in **DNS Manager**, navigated to:

        DNS -> PLUTARCH -> Reverse Lookup Zones -> 154.130.10.in-addr.arpa
		
	and verified that a PTR record had been properly created for
    10.130.154.120, resolving to ansible1.library.arizona.edu.
	
## Create virtual machine.

*   Navigated to https://vc1.library.arizona.edu/, clicked the
    link to access the **vSphere Web Client (Flash)**, and logged in
    using the "administrator@vsphere.local" credentials.
	
*   Navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> (right click) -> New Virtual Machine...
	
	and filled in parameters as follows:

           Provisioning type: Create a new virtual machine
        Virtual machine name: ansible1
                      Folder: LCU
                        Host: smplv1-2-vkm.library.arizona.edu
                   Datastore: SMPLV-DS2
               Guest OS name: CentOS 7 (64-bit)
                        CPUs: 2
                      Memory: 4 GB
                        NICs: 1
               NIC 1 network: LCU1-Scratch-1
                  NIC 1 type: VMXNET 3
           SCSI controller 1: VMware Paravirtual
          Create hard disk 1: New virtual disk
                    Capacity: 20 GB
                   Datastore: SMPLV-DS2
         Virtual device node: SCSI(0:0)
                        Mode: Dependent
               Compatibility: ESXi 6.5 and later (VM version 13)

    and clicked the "Finish" button.

## Install operating system.

*   Still in the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ansible1 -> Configure -> VM hardware -> Edit... -> Virtual Hardware
		
	and added the CentOS 7 installation ISO as follows:
    
             CD/DVD drive 1: Datastore ISO file
                     Status: Connect at power on (checked)
               CD/DVD Media: (SMPLV-ISO) Linux ISOs/CentOS-7-x86_64-Minimal-1708.iso
                Device mode: (greyed out)
        Virtual device node: SATA controller 0, SATA(0:0)
        
    and clicked the "Ok" button.
	
*   Navigated to:
	
		control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ansible1 -> Actions -> Power -> Power on

    and then brought up the console.
	
*   In the console, selected "Install CentOS 7", and then proceeded as follows:

		Install language: English, English (United States)
        Date & time: Americas/Phoenix timezone
        Keyboard: English (US)
        Language support: English (United States)
        Installation source: Local media
        Software selection: Minimal install
        Installation destination: Custom partitioning selected

	        /boot                512 MiB   /dev/sda1
			(swap)              4096 MiB   /dev/sda2
			
			(LVM "centos")      15.5 GiB   /dev/sda3
			
			    /                   5120 MiB   centos-root
			    /var                2048 MiB   centos-var
			    /var/log            1024 MiB   centos-var_log
			    /var/log/audit      1024 MiB   centos-var_log_audit
			    /var/tmp            1024 MiB   centos-var_tmp
			    /tmp                1024 MiB   centos-tmp
			    /home               4604 MiB   centos-home
					
		Kdump: Kdump is enabled
		Network & host name: Wires (ens192) connected

		    Connection name: ens192
			Address: 10.130.154.120
			Netmask: 255.255.255.224
			Gateway: 10.130.154.97
			DNS servers: 150.135.238.4, 150.135.238.30
			Search domains: library.arizona.edu
				
		Security policy: Standard system security policy, Everything okay
		Root password: [set root password]
		Create User:
		
		    Full name: Mike Simpson
			User name: mgsimpson
			Make this user administrator: (checked)
			Require a password to use this account: (checked)

    and clicked "Reboot" once the package installation completed.

*   Once the ansible1 virtual machine finished rebooting, logged into
    the "mgsimpson" account via SSH, and verified sudo access.
	
*   In a **terminal**, logged into ansible1 as "mgsimpson":

		$ sudo yum install open-vm-tools sysstat
        $ sudo yum update
		$ sudo reboot

## Capture state R0.

*   In a **terminal**, logged into ansible1 as "mgsimpson":

        $ sudo shutdown -h now
		
*   In the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ansible1 ->
        (right-click) -> All SimpliVity Actions -> Backup Virtual
		Machine
		
	and set parameters as follows:
	
	        Virtual machine: ansible1
		            Cluster: SMPLV-C1
		            vCenter: control1.library.arizona.edu
		          Datastore: SMPLV-DS2
		               Host: smplv1-1-vkm.library.arizona.edu
		        Backup name: ansible1-R0
		Destination cluster: SMPLV-C1
		
	and clicked "Ok".
		
*   Still in the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ansible1 ->
        (right-click) -> Power -> Power On

    and verified a successful boot via the console.
	
*   In a **terminal**, logged into ansible1 as "mgsimpson" to verify
    availability.
	
## Install latest version Ansible.

*   In a **terminal**, logged into ansible1 as "mgsimpson":

        $ sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		$ sudo yum install ansible

        $ sudo groupadd -g 5000 ansible
        $ sudo useradd -c "Ansible Admin" -d /etc/ansible -g ansible -s /bin/bash -u 5000 ansible-admin
        $ sudo chown -Rh ansible-admin:ansible /etc/ansible
        
            (verify ansible-admin account locked:)
            $ sudo passwd -S ansible-admin
			ansible-admin LK 2018-06-18 0 99999 7 -1 (Password locked.)

            (verify local access and install keypair:)
            $ sudo su - ansible-admin
            
                $ mkdir -m 0700 .ssh
                $ vi .ssh/id_rsa.pub
                
                    (copied from stache.arizona.edu and saved)
                
                $ chmod 444 .ssh/id_rsa.pub
                $ vi .ssh/id_rsa
                
                    (copied from stache.arizona.edu and saved)
                    
                $ chmod 400 .ssh/id_rsa
                $ exit

### Set up Github-managed configuration space.

*   In **Github**, navigated to:

        ualibraries/ansible-config -> Settings -> Deploy keys
		
	and clicked "Add deploy key", then set:
	
	    Title: Ansible Administrator
		Key: (pasted ansible-admin's public key)
		Allow write access: (checked)
		
	and clicked "Add key".

*   In the **terminal**, logged into ansible1 as "mgsimpson":

        $ sudo yum install git
        $ sudo su - ansible-admin
		
		    $ git init
			$ vi .gitignore
			
			    $ cat .gitignore
				.bash*
				.ssh
				
			$ touch roles/.empty
			$ git add .gitignore ansible.cfg hosts roles
			$ git commit -m "Initial commit."
			$ git remote add origin git@github.com:ualibraries/ansible-config.git
			$ git push -u origin master			
            $ exit

## Capture state R1.

*   In a **terminal**, logged into ansible1 as "mgsimpson":

        $ sudo shutdown -h now
		
*   In the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ansible1 ->
        (right-click) -> All SimpliVity Actions -> Backup Virtual
		Machine
		
	and set parameters as follows:
	
	        Virtual machine: ansible1
		            Cluster: SMPLV-C1
		            vCenter: control1.library.arizona.edu
		          Datastore: SMPLV-DS2
		               Host: smplv1-1-vkm.library.arizona.edu
		        Backup name: ansible1-R1
		Destination cluster: SMPLV-C1
		
	and clicked "Ok".
		
*   Still in the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ansible1 ->
        (right-click) -> Power -> Power On

    and verified a successful boot via the console.
	
*   In a **terminal**, logged into ansible1 as "mgsimpson" to verify
    availability.

# POST-STATE-R1

	(added to /etc/ssh/ssh_config on my laptop:)

        XAuthLocation /opt/X11/bin/xauth

    (on ansible1:)

        $ sudo yum install zsh emacs xorg-x11-xauth
	
	(this lets me run:)
	
	    % ssh -Yt mgsimpson@ansible1.library.arizona.edu emacs
		
    (support for vmware module in Ansible:)
	
		% sudo yum install python2-pip
	    % sudo pip install pyvmomi
