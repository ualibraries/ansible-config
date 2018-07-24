# Notes for build of openaz-[tmpl|tst|stg|prd].library.arizona.edu.

## Prerequisite steps.

### Local platform.

Apple MacBook Pro (Retina, 15-inch, Mid 2015) w/16 GB RAM, running
macOS Sierra 10.12.6.

Using Emacs 25.3 for an IDE, installed from https://emacsformacosx.com/.

### Establish DNS entries for Open Arizona hosts.

#### Reserve IP addresses.

*   In **Box**, navigated to:

        All Files -> TeSS Limited Access -> IP Addresses
		
	and opened "LCU-IPs.xlsx".
	
*   On the "LCU1-Test (206)" tab, added an entry:
	
	    IP Address: 10.130.155.13
		Hostname: openaz-tmpl.library.arizona.edu
		Purpose: Template virtual machine for Open Arizona service.
		Notes: mgsimpson, 6/23/2018

*   On the "LCU-Public (199)" tab, added entries:

	    IP Address: 150.135.174.13
		Hostname: openaz-tst.library.arizona.edu
		Purpose: Testing environment for Open Arizona project.
		Notes: mgsimpson, 6/23/2018

	    IP Address: 150.135.174.14
		Hostname: openaz-stg.library.arizona.edu
		Purpose: Staging environment for Open Arizona project.
		Notes: mgsimpson, 6/23/2018

	    IP Address: 150.135.174.15
		Hostname: openaz-prd.library.arizona.edu
		Purpose: Production environment for Open Arizona project.
		Notes: mgsimpson, 6/23/2018; CNAME open.uapress.arizona.edu

#### Configure DNS records.

*   Using **Microsoft Remote Desktop**, connected to:

        plutarch.library.arizona.edu
		
	using my library domain credentials.
	
*   Opened **DNS Manager**, navigated to:

        DNS -> PLUTARCH- > Forward Lookup Zones -> library.arizona.edu
	
*   Right-clicked, chose "New Host (A or AAAA)...", filled in "New Host"
    dialogue as:
	
	    Name: openaz-tmpl
		FQDN: openaz-tmpl.library.arizona.edu
		IP address: 10.130.155.13
		Create associated pointer (PTR) record: (checked)
		
    and clicked "Add Host".

*   Repeated the above for "openaz-tst", "openaz-stg" and "openaz-prd"
	entries.

*   Still in **DNS Manager**, under "Reverse Lookup Zones", verified
    that the PTR records for the above four hosts had been correctly
	configured.

*   Still in **DNS Manager**, under "Forward Lookup Zones", created
    a CNAME record for "open.uapress.arizona.edu", pointed at 
	"openaz-prd.library.arizona.edu".

## Create template virtual machine.

*   Navigated to https://vc1.library.arizona.edu/, clicked the
    link to access the **vSphere Web Client (Flash)**, and logged in
    using the "administrator@vsphere.local" credentials.
	
*   Navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> (right click) -> New Virtual Machine...
	
	and filled in parameters as follows:

           Provisioning type: Create a new virtual machine
        Virtual machine name: openaz-tmpl
                      Folder: LCU
                        Host: smplv1-2-vkm.library.arizona.edu
                   Datastore: SMPLV-DS2
               Guest OS name: Ubuntu Linux (64-bit)
                        CPUs: 2
                      Memory: 8 GB
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

*   Still in the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> openaz-tmpl -> Configure -> VM hardware -> Edit... -> Virtual Hardware
		
	and added the Ubuntu 16 installation ISO as follows:
    
             CD/DVD drive 1: Datastore ISO file
                     Status: Connect at power on (checked)
               CD/DVD Media: (SMPLV-ISO) Linux ISOs/ubuntu-16.04.4-server-amd64.iso
			    Device mode: (greyed out)
        Virtual device node: SATA controller 0, SATA(0:0)
        
    and clicked the "Ok" button.
	
*   Navigated to:
	
		control1.library.arizona.edu -> LCU -> SMPLV-C1 -> openaz-tmpl -> Actions -> Power -> Power on

    and then brought up the console.
	
*   In the console, went through the Ubuntu installation process as follow:

        Console -> English -> Install Ubuntu Server
        
            Language: English
            Country, territory or area: United States
            Detect keyboard layout: No
            Configure the keyboard: English (US)
            Configure network manually:
            
                IP address: 10.130.155.13
                Netmask: 255.255.255.0
                Gateway: 10.130.155.1
                Name servers: 150.135.238.4 150.135.238.30
                Hostname: openaz-tmpl
                Domain name: library.arizona.edu
                User account:
                
                    Full name: Mike Simpson
                    Username: mgsimpson
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

*   Verified access as "mgsimpson" via console and remote terminal.

*   In a local terminal:

        % ssh mgsimpson@openaz-tmpl.library.arizona.edu
    
            $ sudo apt-get install open-vm-tools
			$ sudo apt update
			$ sudo apt upgrade
            $ sudo reboot

*   In a local terminal:

        % ssh mgsimpson@openaz-tmpl.library.arizona.edu
		
		    (install ansible target prerequisites:)
		    $ sudo apt install python
			
			(create ansible-admin group and user:)
            $ sudo groupadd -g 5000 ansible
            $ sudo useradd -c "Ansible Admin" -d /etc/ansible -g ansible -s /bin/bash -u 5000 ansible-admin
			$ sudo mkdir /etc/ansible
            $ sudo chown -Rh ansible-admin:ansible /etc/ansible
        
            (verify ansible-admin account locked:)
            $ sudo passwd -S ansible-admin
			ansible-admin LK 2018-06-18 0 99999 7 -1 (Password locked.)

            (verify local access and install authorized keys:)
            $ sudo su - ansible-admin
            
                $ mkdir -m 0700 .ssh
                $ vi .ssh/authorized_keys
                
                    (copied public key from stache.arizona.edu and saved)
                
                $ chmod 444 .ssh/authorized_keys
                $ exit

            (enable privilege escalation for ansible group:)
            $ sudo visudo
        
                (added no-password privilege escalation for "ansible" group)
            
		    $ exit

*   In a local terminal:

        $ ssh mgsimpson@openaz-tmpl.library.arizona.edu
		
		    $ sudo su - ansible-admin
			
			    $ crontab -e
				
				  (added ping-on-reboot syntax to refresh arp cache after template customization)
				  
			    $ exit

*   In a local terminal:

        % ssh mgsimpson@openaz-tmpl.library.arizona.edu
		
		    $ sudo shutdown -h now
		
*   In the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> openaz-tmpl ->
        (right-click) -> Template -> Convert to Template

    Moved the now-template virtual machine to:
	
	    control1.library.arizona.edu -> LCU -> Service Templates

    Then created a SimpliVity backup of the template VM as:

                VM template: openaz-tmpl
		            Cluster: SMPLV-C1
		            vCenter: control1.library.arizona.edu
		          Datastore: SMPLV-DS2
		               Host: smplv1-1-vkm.library.arizona.edu
		        Backup name: openaz-tmpl-R0
		Destination cluster: SMPLV-C1
		
	and clicked "Ok".
