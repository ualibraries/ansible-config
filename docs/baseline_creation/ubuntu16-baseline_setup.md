# Notes for build of ubuntu16-baseline.library.arizona.edu.

## Establish DNS entries.

*   In **Box**, navigated to:

        All Files -> TeSS Limited Access -> IP Addresses
		
	and opened "LCU-IPs.xlsx".
	
*   On the "LCU1-Test (206)" tab, chose an unused IP address and
    annotated as follows:
	
	    IP Address: 10.130.155.11
		Hostname: ubuntu16-baseline.library.arizona.edu
		Purpose: Template Ubuntu 16 virtual machine.
		Notes: mgsimpson, 8/17/2018

*   Using **Microsoft Remote Desktop**, connected to:

        plutarch.library.arizona.edu
		
	using my library domain credentials.
	
*   Opened **DNS Manager**, navigated to:

        DNS -> PLUTARCH- > Forward Lookup Zones -> library.arizona.edu
	
*   Right-clicked, chose "New Host (A or AAAA)...", filled in "New Host"
    dialogue as:
	
	    Name: ubuntu16-baseline
		FQDN: ubuntu16-baseline.library.arizona.edu
		IP address: 10.130.155.11
		Create associated pointer (PTR) record: (checked)
		
    and clicked "Add Host".
	
*   Still in **DNS Manager**, navigated to:

        DNS -> PLUTARCH -> Reverse Lookup Zones -> 155.130.10.in-addr.arpa
		
	and verified that a PTR record had been properly created for
    10.130.155.11, resolving to ubuntu16-baseline.library.arizona.edu.

## Create virtual machine.

*   Navigated to https://vc1.library.arizona.edu/, clicked the
    link to access the **vSphere Web Client (Flash)**, and logged in
    using the "administrator@vsphere.local" credentials.
	
*   Navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> (right click) -> New Virtual Machine...
	
	and filled in parameters as follows:

           Provisioning type: Create a new virtual machine
        Virtual machine name: ubuntu16-baseline
                      Folder: Service Templates
                        Host: smplv1-2-vkm.library.arizona.edu
                   Datastore: SMPLV-DS2
               Guest OS name: Ubuntu Linux (64-bit)
                        CPUs: 2
                      Memory: 4 GB
                        NICs: 1
               NIC 1 network: LCU1-Test
                  NIC 1 type: VMXNET 3
           SCSI controller 1: LSI Logic Parallel
          Create hard disk 1: New virtual disk
                    Capacity: 20 GB
                   Datastore: SMPLV-DS2
         Virtual device node: SCSI(0:0)
                        Mode: Dependent
               Compatibility: ESXi 6.5 and later (VM version 13)

    and clicked the "Finish" button.

## Install operating system.

*   Still in the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ubuntu16-baseline -> Configure -> VM hardware -> Edit... -> Virtual Hardware
		
	and added the Ubuntu 16 installation ISO as follows:
    
             CD/DVD drive 1: Datastore ISO file
                     Status: Connect at power on (checked)
               CD/DVD Media: (SMPLV-ISO) Linux ISOs/ubuntu-16.04.4-server-amd64.iso
			    Device mode: (greyed out)
        Virtual device node: SATA controller 0, SATA(0:0)
        
    and clicked the "Ok" button.
	
*   Navigated to:
	
		control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ubuntu16-baseline -> Actions -> Power -> Power on

    and then brought up the console.
	
*   In the console, went through the Ubuntu installation process as follow:

        Console -> English -> Install Ubuntu Server
        
            Language: English
            Country, territory or area: United States
            Detect keyboard layout: No
            Configure the keyboard: English (US)
            Configure network manually:
            
                IP address: 10.130.155.11
                Netmask: 255.255.255.0
                Gateway: 10.130.155.1
                Name servers: 150.135.238.4 150.135.238.30
                Hostname: ubuntu16-baseline
                Domain name: library.arizona.edu
                User account:
                
                    Full name: Mike Simpson
                    Username: mgsimpson
					Password: (password)
                    Encrypt home directory: No
                
                Timezone: America/Phoenix

            Disk partitioning: Manual

                /boot                512 MiB   /dev/sda1
			    (swap)              4096 MiB   /dev/sda2
			
			    (LVM "ubuntu")      15.5 GiB   /dev/sda3
			
			        /                   5120 MiB   ubuntu-root
			        /var                2048 MiB   ubuntu-var
			        /var/log            1024 MiB   ubuntu-var_log
			        /var/log/audit      1024 MiB   ubuntu-var_log_audit
			        /var/tmp            1024 MiB   ubuntu-var_tmp
			        /tmp                1024 MiB   ubuntu-tmp
			        /home               5607 MiB   ubuntu-home
					
			Updates: No automatic updates
			Software to install: Standard system utilities, OpenSSH server
			Install GRUB boot loader to MBR: Yes
			
			-> Reboot

*   Since the installation media was still mounted, the first reboot
    went straight back into the installation sequence; powered off the
	virtual machine, reconfigured to remove the DVD mount-on-boot, and
    then rebooted a second time to get to the newly-installed OS.

*   Once the ubuntu16-baseline virtual machine finished rebooting,
    logged into the "mgsimpson" account via the console and via SSH to
    verify access.

## Post-installation setup.

### Install VMware tools and patch to current.

*   In a **terminal**, logged into ubuntu16-baseline as "mgsimpson":

        $ sudo apt-get install open-vm-tools
		$ sudo apt update
		$ sudo apt upgrade
		$ sudo reboot

## Add ping-on-reboot crontab entry for ARP cache refresh.

*   In a **terminal**, logged into ubuntu16-baseline as "mgsimpson":

        $ sudo su -
		
		    # crontab -e
            (edited crontab)

            # crontab -l
            @reboot ping -c 3 `ip route show | grep -oP '(?<=^default via )(.*)(?= dev ens160)'` > ping.boot

### Install Ansible client node prerequisites.

*   In a **terminal**, logged into ubuntu16-baseline as "mgsimpson":

	    (installed python interpreter:)
	    $ sudo apt-get install python
		
		(create ansible-admin group and user:)
        $ sudo groupadd -g 5000 ansible
        $ sudo useradd -c "Ansible Admin" -d /etc/ansible -m -g ansible -s /bin/bash -u 5000 ansible-admin
        
        (verify ansible-admin account locked:)
        $ sudo  passwd -S ansible-admin
		ansible-admin L 08/17/2018 0 99999 7 -1

        (verify local access and install authorized keys:)
        $ sudo su - ansible-admin
            
            $ mkdir -m 0700 .ssh
            $ vi .ssh/authorized_keys
                
                (copied public key from stache.arizona.edu and saved)
                
            $ chmod 444 .ssh/authorized_keys
            $ exit

        (enable privilege escalation for ansible admin user:)
        $ sudo visudo
        
            (added no-password privilege escalation for "ansible-admin" user)

## Convert to template and capture state zero.

*   In a **terminal**, logged into ubuntu16-baseline as "mgsimpson":

        $ sudo shutdown -h now

*   In the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> ubuntu16-baseline ->
        (right-click) -> Template -> Convert to Template

*   Still in vSphere, created a SimpliVity backup of the template VM as:

                VM template: ubuntu16-baseline
		            Cluster: SMPLV-C1
		            vCenter: control1.library.arizona.edu
		          Datastore: SMPLV-DS2
		               Host: smplv1-1-vkm.library.arizona.edu
		        Backup name: ubuntu16-baseline-0
		Destination cluster: SMPLV-C1
		
	and clicked "Ok".
