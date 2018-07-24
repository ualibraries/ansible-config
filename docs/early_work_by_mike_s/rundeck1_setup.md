# Notes for build of rundeck1.library.arizona.edu.

## Prerequisite steps.

### Local platform.

Apple MacBook Pro (Retina, 15-inch, Mid 2015) w/16 GB RAM, running
macOS Sierra 10.12.6.

Using Emacs 25.3 for an IDE, installed from https://emacsformacosx.com/.

### Establish DNS entry for Rundeck control host.

#### Reserve IP address.

*   In **Box**, navigated to:

        All Files -> TeSS Limited Access -> IP Addresses
		
	and opened "LCU-IPs.xlsx".
	
*   On the "LCU1-Scratch-1 (204)" tab, chose an unused IP address and
    annotated as follows:
	
	    IP Address: 10.130.154.121
		Hostname: rundeck1.library.arizona.edu
		Purpose: Rundeck control host for LCU1 deployments.
		Notes: mgsimpson, 7/3/2018

#### Configure DNS records.

*   Using **Microsoft Remote Desktop**, connected to:

        plutarch.library.arizona.edu
		
	using my library domain credentials.
	
*   Opened **DNS Manager**, navigated to:

        DNS -> PLUTARCH- > Forward Lookup Zones -> library.arizona.edu
	
*   Right-clicked, chose "New Host (A or AAAA)...", filled in "New Host"
    dialogue as:
	
	    Name: rundeck1
		FQDN: rundeck1.library.arizona.edu
		IP address: 10.130.154.121
		Create associated pointer (PTR) record: (checked)
		
    and clicked "Add Host".
	
*   Still in **DNS Manager**, navigated to:

        DNS -> PLUTARCH -> Reverse Lookup Zones -> 154.130.10.in-addr.arpa
		
	and verified that a PTR record had been properly created for
    10.130.154.121, resolving to rundeck1.library.arizona.edu.
	
## Create virtual machine.

*   Navigated to https://vc1.library.arizona.edu/, clicked the
    link to access the **vSphere Web Client (Flash)**, and logged in
    using the "administrator@vsphere.local" credentials.
	
*   Navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> (right click) -> New Virtual Machine...
	
	and filled in parameters as follows:

           Provisioning type: Create a new virtual machine
        Virtual machine name: rundeck1
                      Folder: Support VMs
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

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> rundeck1 -> Configure -> VM hardware -> Edit... -> Virtual Hardware
		
	and added the CentOS 7 installation ISO as follows:
    
             CD/DVD drive 1: Datastore ISO file
                     Status: Connect at power on (checked)
               CD/DVD Media: (SMPLV-ISO) Linux ISOs/CentOS-7-x86_64-Minimal-1708.iso
                Device mode: (greyed out)
        Virtual device node: SATA controller 0, SATA(0:0)
        
    and clicked the "Ok" button.
	
*   Navigated to:
	
		control1.library.arizona.edu -> LCU -> SMPLV-C1 -> rundeck1 -> Actions -> Power -> Power on

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
			    /home               4600 MiB   centos-home
					
		Kdump: Kdump is enabled
		Network & host name: Wired (ens192) connected

		    Connection name: ens192
			Address: 10.130.154.121
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

*   Once the rundeck1 virtual machine finished rebooting, logged into
    the "mgsimpson" account via SSH, and verified sudo access.
	
*   In a **terminal**, logged into ansible1 as "mgsimpson":

		$ sudo yum install open-vm-tools sysstat
        $ sudo yum update
		$ sudo reboot

## Capture state R0.

*   In a **terminal**, logged into ansible1 as "mgsimpson":

        $ sudo shutdown -h now
		
*   In the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> rundeck1 ->
        (right-click) -> All SimpliVity Actions -> Backup Virtual
		Machine
		
	and set parameters as follows:
	
	        Virtual machine: rundeck1
		            Cluster: SMPLV-C1
		            vCenter: control1.library.arizona.edu
		          Datastore: SMPLV-DS2
		               Host: smplv1-2-vkm.library.arizona.edu
		        Backup name: rundeck1-R0
		Destination cluster: SMPLV-C1
		
	and clicked "Ok".
		
*   Still in the **vSphere Web Client (Flash)**, navigated to:

        control1.library.arizona.edu -> LCU -> SMPLV-C1 -> rundeck1 ->
        (right-click) -> Power -> Power On

    and verified a successful boot via the console.
	
*   In a **terminal**, logged into ansible1 as "mgsimpson" to verify
    availability.
	
## Install latest version Rundeck.

*   In a **terminal**, logged into ansible1 as "mgsimpson":

        $ sudo rpm -Uvh http://repo.rundeck.org/latest.rpm
		$ sudo yum install java rundeck
        $ sudo firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=4440
		$ sudo firewall-cmd --reload
		$ cd /etc/rundeck
		$ sudo cp -p framework.properties framework.properties.dist

            $ sudo diff framework.properties.dist framework.properties
            11c11
            < framework.server.url = http://localhost:4440
            ---
            > framework.server.url = http://rundeck1.library.arizona.edu
			
		$ sudo cp -p rundeck-config.properties rundeck-config.properties.dist
		
		    $ sudo diff rundeck-config.properties.dist rundeck-config.properties
            8c8
            < grails.serverURL=http://localhost:4440
            ---
            > grails.serverURL=http://rundeck1.library.arizona.edu
			
		$ cd
		$ sudo service rundeckd start


# WORK CEASED AT THIS POINT.
