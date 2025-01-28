# Lab 05 Software Hardening
This lab is intended to give you a taste of hardening software in Linux. It is neither an exhaustive list of recommendations or even a list of things that apply to all systems. It is simply meant to give you practice in changing software settings and testing those changes.

## Grading
This lab counts for marks. You will be creating a single PDF file to submit to Blackboard for this lab. For the questions, include the question and your response. For the screenshots, you only need to include enough in your screenshots to show your bash prompt, the command you ran, and the output that demonstrates what you did or that the command works. For the roundcube web page screenshot, you only need to show the login succeeded as there is no email in the account.

## Over-riding default file permissions in package executables
1. Following the example in the slides, modify your sudo executable to only be accessible for execution by the file owner and the file's group
```bash
sudo dpkg-statoverride --update --add root sudo 4550 /usr/bin/sudo
```
1. Before exiting your current bash session, start a second terminal window and ensure you can still use sudo
1. Does debsums complain about your modified sudo program? How about dpkg with the verify option? - *submission question!*
```bash
debsums sudo | grep /usr/bin/sudo
sudo dpkg --verify sudo
```
1. Use the list option of dpkg-statoverride to view all programs with overrides on your system - *screenshot!*
```bash
dpkg-statoverride --list
```

## Apparmor
1. Run aa-status to see what the current state of apparmor is on your VM
```bash
sudo aa-status
```
1. Try the aa-unconfined utility to see what processes are running that have tcp or udp ports and their apparmor status
```bash
sudo aa-unconfined
```
1. Review the list of profiles contained in the [Ubuntu 20.04 apparmor-profiles](https://packages.ubuntu.com/focal/all/apparmor-profiles/filelist) package
1. Are there profiles in that package for the /etc/apparmor.d directory which would confine software that is running unconfined on your system now? - *submission question!*
1. Try using the --paranoid option for aa-unconfined to see if there are processes which could be confined by the apparmor-profiles package which aa-unconfined did not show without that option
```bash
sudo aa-unconfined --paranoid
```
1. Review the content of the apprmor profile for the tcpdump network snooping program
```bash
cat /etc/apparmor.d/usr.sbin.tcpdump
```
1. Using the apparmor man page, can you determine the kinds of limitations that are placed on that program by that profile? - *submission question!*

## sudo configuration
[Digital Ocena's tips page for sudo privileges](https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file) is a helpful helpful resource when looking for how to edit sudo permissions.
1. Modify your sudo executable to be accessible for execution by any user, so that we can use the sudoers file to control access instead
```bash
sudo dpkg-statoverride --update --add root sudo 4555 /usr/bin/sudo
```
1. Modify your /etc/sudoers file to limit the `dennis` account so that they can only use root sudo to edit their own domain zone file (`/etc/bind/db.simpson22725.mytld`) and reload named using the `rndc reload` command
```bash
visudo
```
1. In a second ssh session, login as user `dennis` (password is `dennis`) and verify that user dennis can use sudo to edit their zone file and to run `rndc reload` but cannot use sudo to run another command like `bash`
```bash
dennis$ sudo vi /etc/bind/db.simpson22725.mytld
dennis$ sudo rndc reload
dennis$ sudo bash
```
1. List out the sudo configuration for user dennis - *screenshot!*
```bash
dennis$ sudo -l
```

## BIND improvements
1. Following the information given in [Chapter 6 of the Bind9 Administrator's Reference Manual (ARM)](https://bind9.readthedocs.io/en/latest/chapter6.html), secure your bind service by:
   * adding the bogusnets acl as shown in the ARM (in /etc/bind/named.conf.options)
   * setting up the allow-query, allow-recursion, and blackhole directives as shown in the ARM (in /etc/bind/named.conf.options)
   * allowing queries from anywhere for the zones being served by the server (in named.conf.local)
1. Verify your DNS service reloads the new configuration properly - *screenshot!*
```bash
sudo rndc reload
```
1. Verify your own DNS lookups still work and show the content of your named.conf files that were changed - *screenshot!*
```bash
nslookup www.simpson22725.mytld
cat /etc/bind/named.conf.local /etc/bind/named.conf.options
```
1. In a terminal or powershell window on your host laptop/computer, run `nslookup www.simpson22725.mytld ip-of-your-vm` to verify your domain service is still available to non-local clients - *screenshot!*

## MySQL basic hygiene
1. Run the mysql_secure_installation script to clean up after the install - *screenshot!*
   * **do not enable password validation**
   * set the root password to `root`
   * remove anonymous users
   * disallow remote root login
   * remove the test database
   * reload the privilege tables
1. Access the web page at http://your-vm-ip/roundcube and put in the student account name and password, server `localhost` to verify that the mysql database service is still running properly - *screenshot!*

## Email client access
1. Identify what you would need to change to disallow POP3 and IMAP service in your dovecot configuration whithout interfering with POP3S and IMAPS service - *submission question!*
1. What firewall changes would you make to the existing VM to limit email clients to only POP3S and IMAPS? - *submission question!*

## Known vulnerabilities
1. Is your VM susceptible to the [bash shell shock vulnerability](https://linux-audit.com/protect-shellshock-bash-vulnerability)? Show what you did to check. - *submission question!*
1. Is your VM susceptible to the [heartbleed vulnerability](https://heartbleed.com)? Show what you did to check. - *submission question!*

## Unexpected programs on your system
1. Create a command or script to find executables that were not installed by system packages - *submission question!*
1. Can you identify where all of the programs might have come from that it finds? - *submission question!*

