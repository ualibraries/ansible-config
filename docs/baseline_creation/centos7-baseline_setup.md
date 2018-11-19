# Notes for build of centos7-baseline.library.arizona.edu.

## Establish DNS entries.

*   In **Box**, navigated to:

        All Files -> TeSS Limited Access -> IP Addresses
		
	and opened "LCU-IPs.xlsx".
	
*   On the "LCU1-Test (206)" tab, chose an unused IP address and
    annotated as follows:
	
	    IP Address: 10.130.155.10
		Hostname: centos7-baseline.library.arizona.edu
		Purpose: Template Centos 7 virtual machine.
		Notes: mgsimpson, 8/17/2018

*   Using **Microsoft Remote Desktop**, connected to:

        plutarch.library.arizona.edu
		
	using my library domain credentials.
	
*   Opened **DNS Manager**, navigated to:

        DNS -> PLUTARCH- > Forward Lookup Zones -> library.arizona.edu
	
*   Right-clicked, chose "New Host (A or AAAA)...", filled in "New Host"
    dialogue as:
	
	    Name: centos7-baseline
		FQDN: centos7-baseline.library.arizona.edu
		IP address: 10.130.155.10
		Create associated pointer (PTR) record: (checked)
		
    and clicked "Add Host".
	
*   Still in **DNS Manager**, navigated to:

        DNS -> PLUTARCH -> Reverse Lookup Zones -> 155.130.10.in-addr.arpa
		
	and verified that a PTR record had been properly created for
    10.130.155.10, resolving to centos7-baseline.library.arizona.edu.
	
## Create virtual machine.

*   Navigated to https://control1-smplv.library.arizona.edu/, clicked the
    link to access the **vSphere Web Client (Flash)**, and logged in
    using the "administrator@vsphere.local" credentials.
	
*   Navigated to:

        control1-smplv.library.arizona.edu -> LCU -> SMPLV-C1 -> (right click) -> New Virtual Machine...
	
	and filled in parameters as follows:

           Provisioning type: Create a new virtual machine
        Virtual machine name: centos7-baseline
                      Folder: Service Templates
                        Host: smplv1-2-vkm.library.arizona.edu
                   Datastore: SMPLV-DS2
               Guest OS name: CentOS 7 (64-bit)
                        CPUs: 2
                      Memory: 4 GB
                        NICs: 1
               NIC 1 network: LCU1-Test
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

        control1-smplv.library.arizona.edu -> LCU -> SMPLV-C1 -> centos7-baseline -> Configure -> VM hardware -> Edit... -> Virtual Hardware
		
	and added the CentOS 7 installation ISO as follows:
    
             CD/DVD drive 1: Datastore ISO file
                     Status: Connect at power on (checked)
               CD/DVD Media: (SMPLV-ISO) Linux ISOs/CentOS-7-x86_64-Minimal-1804.iso
                Device mode: (greyed out)
        Virtual device node: SATA controller 0, SATA(0:0)
        
    and clicked the "Ok" button.
	
*   Navigated to:
	
		control1-smplv.library.arizona.edu -> LCU -> SMPLV-C1 -> centos7-baseline -> Actions -> Power -> Power on

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
			    /home               4598 MiB   centos-home
					
		Kdump: Kdump is enabled
		Network & host name: Wired (ens192) connected

		    Connection name: ens192
			Address: 10.130.155.10
			Netmask: 255.255.255.0
			Gateway: 10.130.155.1
			DNS servers: 150.135.238.4, 150.135.238.30
			Search domains: library.arizona.edu
			Host name: centos7-baseline
			
		Security policy: No profile selected.
		Root password: (set root password)
		Create User: (no user created)
		
    and clicked "Reboot" once the package installation completed.

*   Since the installation media was still mounted, the first reboot
    went straight back into the installation sequence; powered off the
	virtual machine, reconfigured to remove the DVD mount-on-boot, and
    then rebooted a second time to get to the newly-installed OS.

*   Once the centos7-baseline virtual machine finished rebooting,
    logged into the root account via the console and via SSH to verify
    access using the root account.

## Post-installation setup.

### Install VMware tools and patch to current.

*   In a **terminal**, logged into centos7-baseline as "root":

		# yum install open-vm-tools
        # yum update
		# reboot

## Add ping-on-reboot crontab entry for ARP cache refresh.

*   In a **terminal**, logged into centos7-baseline as "root":

        # crontab -e
		(edited crontab)

		# crontab -l
        @reboot ping -c 3 `ip route show | grep -oP '(?<=^default via )(.*)(?= dev ens192)'` > ping.boot

### Install Ansible client node prerequisites.

*   In a **terminal**, logged into centos7-baseline as "root":

	    (verified python interpreter already installed:)
	    # which python
		/usr/bin/python
		
		(create ansible-admin group and user:)
        # groupadd -g 5000 ansible
        # useradd -c "Ansible Admin" -d /etc/ansible -m -g ansible -s /bin/bash -u 5000 ansible-admin
        
        (verify ansible-admin account locked:)
        # passwd -S ansible-admin
		ansible-admin LK 2018-11-01 0 99999 7 -1 (Password locked.)

        (verify local access and install authorized keys:)
        # su - ansible-admin
            
            $ mkdir -m 0700 .ssh
            $ vi .ssh/authorized_keys
                
                (copied public key from stache.arizona.edu and saved)
                
            $ chmod 444 .ssh/authorized_keys
            $ exit

        (enable privilege escalation for ansible admin user:)
        # visudo
        
            (added no-password privilege escalation for "ansible-admin" user)

## Convert to template and capture state.

*   In a **terminal**, logged into centos7-baseline as "root":

        # shutdown -h now

*   In the **vSphere Web Client (Flash)**, navigated to:

        control1-smplv.library.arizona.edu -> LCU -> SMPLV-C1 -> centos7-baseline ->
        (right-click) -> Template -> Convert to Template

*   In the **vSphere Web Client (Flash)**, navigated to:

        control1-smplv.library.arizona.edu -> LCU -> SMPLV-C1 -> centos7-baseline ->
        (right-click) -> Clone to Template
		
		  Provisioning type: Clone template to template
		    Source template: centos7-baseline
		      Template name: centos7-baseline-20181102-1
		             Folder: Service Templates
		               Host: smplv1-2-vkm.library.arizona.edu
		          Datastore: SMPLV-DS2
		       Disk storage: Same format as source

    and clicked "Finish".
