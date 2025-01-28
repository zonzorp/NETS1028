# NETS1028 Lab 01 Security Design

## Lab VM description and purpose
For this course, we will use a pre-built and configured Ubuntu 20.04 Linux server running under VMWare. It is a machine which is built as part of another college course, and was not set up with security in mind. It has several services running, a firewall enabled, and lives on multiple networks. Treat this as if it were an existing server running in the business of your new employer. It is supposed to be providing:
- custom internal dns service only to the internal network
- web pages on hostname www in the private domain
- pages and webapps on hostname secure in the private domain
- various web apps for administrative purposes
- personal web pages for staff who have accounts on the machine
- database services to local applications
- ssh access to clients on the internal network
- vpn access to the internal network from the outside world
- email services to the internal network
- file sharing services to Windows machines on the internal networks
- PDF file printing services for the internal networks

## Obtaining and setting up your lab VM
Follow these steps to download a suitable VM for our course and customize it so that your VM is specific to you for the purpose of grading.

1. Download the [course VM](https://zonzorp.net/gc/NETS1028-VM.ova) and open it in VMWare. There are 2 network interfaces in the VM. The first should be bridged to your LAN, the second should be set to a host-only virtual network.
1. Boot the VM, and login as student with password Password123. The student user has sudo privileges.
1. Create a user account for your use during the semester. Use your first name for the username. Give it a password you can remember. Add it to the sudo group so that you can use sudo from that account. Log out of the student account and log into your own personal account.
1. Test that sudo works properly, and only use your own personal account on the lab VM for the rest of the semester unless explicitly instructed otherwise during the semester.
1. Take note of your LAN address for the VM. You will need to know it for remote access from your laptop. The VM has SSH enabled and using putty (Terminal if you are on a Mac) or a similar tool is the recommended method to access the machine for command line use.
1. Run ```apt-get update``` and ```apt-get upgrade``` to bring the base system up to current software versions.

## Security Design Exercises
These exercises will help you to become familiar with some of the security features and limitations of your installation. All of these are to be investigated for the previously downloaded pre-built VM running Ubuntu 20.04.

### Physical Security
1. Describe command(s) or configuration file(s) which may be used to disable ctrl-alt-del reboot.
1. Describe how to prevent removable media filesystems from being automatically mounted.

### Boot Security
1. Identify how to add a password to your boot loader so that it is required before a user can alter the boot parameters.
1. Identify the command(s) to automatically remove old kernel versions from your system.

### Service Availability
1. What command(s) are used to start, stop, and check status of installed services? Give examples of starting stopping, and status checking at least 2 services that are running on your VM.
1. **Other than service control commands like you used in the previous step**, describe at least one other way to determine what services your server may be providing?

### User Access
1. What Linux user accounts are on your server now? For each account you found, describe its purpose.
1. Which accounts can be used to log in by end users (i.e. they have a user-oriented general purpose shell and are not locked)?

## Helpful Resources
###References and Links (Useful for finding answers to Lab 1 questions)
* Grab a copy of [Ubuntu Server Docs](https://ubuntu.com/server/docs)
  * can find information on ctrl+alt+del handling and more
* Debian Documentation on [udisks2](https://packages.debian.org/buster/udisks2) package
* [GRUB Bootloader Documentation](https://www.gnu.org/software/grub/manual/grub/grub.html)
  * For Lab 1 pay special attention to "18 - Security", and "[18.1 Authentication and authorization in GRUB](https://www.gnu.org/software/grub/manual/grub/grub.html#Authentication-and-authorisation)"
* Ubuntu documentation on [Removing Old Kernels](https://help.ubuntu.com/community/RemoveOldKernels)
* The Linux Document Project (TLDP.org)
* Guides: [Linux Document Project Guides](https://tldp.org/guides.html)
* Linux [HOWTO-INDEX](https://tldp.org/HOWTO/HOWTO-INDEX/index.html)
* Security [Quick-Start HOWTO for Linux](https://tldp.org/HOWTO/Security-Quickstart-HOWTO/)
  * For Lab 1: read "[3. Step 1: Which services do we really need?](https://tldp.org/HOWTO/Security-Quickstart-HOWTO/services.html)"
* Man pages for the passwd and shadow files (included in your Linux system, use man 5 passwd and man 5 shadow commands
* Debian documentation on system groups and their description: [wiki.debian.org/SystemGroups](https://wiki.debian.org/SystemGroups)

## Grading
Submit a PDF document (no other formats will be accepted) with the list of questions above and your answers. You must include the questions above in your submitted document. Copy/paste them if you wish. Your answers must be your own work, in your own words.
