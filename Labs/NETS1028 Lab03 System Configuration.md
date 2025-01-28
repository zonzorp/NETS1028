# Lab03 System Configuration
This lesson examines some broad configuration topics. Further detail on configuring specific services and options are contained in other units. In order to ensure each student's screenshots are coming from their lab VM, begin by changing your system's hostname from `pc20022725` to `pcNNNNNNNNN` where NNNNNNNNN is your own student number. Your screenshots will then show the hostname in the shell prompts so I can verify your work was done on your machine. Submissions which do not have your student number in your hostname showing in the shell prompts will not be marked.

## Unattended Upgrades
The unattended upgrades service uses a configuration file that contains runtime settings and rules. If you change the configuration, you need to restart the service. How much and whether to use the service is a topic for debate on servers, but it should be run on desktops at a minimum.

1. Install and enable the unattended-upgrades package if you need to. Also install the mailutils package if necessary to allow for local email progress reporting.
```bash
sudo apt install unattended-upgrades mailutils
sudo dpkg-reconfigure unattended-upgrades
```
1. Modify the configuration of the unattended-upgrades package to send email when doing upgrades. Look for email-related settings. They are about halfway through the config file. Send email to student whenever there are changes made by the upgrade service. Restart the service after you make changes so they take effect.
```bash
sudo vi /etc/apt/apt.conf.d/50unattended-upgrades
sudo systemctl restart unattended-upgrades
```
1. Review the contents of the unattended-upgrades logfiles to see what gets logged there.
```bash
sudo tail -30 /var/log/unattended-upgrades/unattended-upgrades.log
sudo tail -30 /var/log/unattended-upgrades/unattended-upgrades-dpkg.log
```

## Identifying Running Services to determine if they should be removed
There are multiple ways to determine which services are running, but the decisions about which ones need to be running are based on the system's intended functions and any organizational policies that may apply.

1. Identify services which are managed by systemd
```bash
systemctl -t service
```
1. For every service listed that is unfamiliar, you might need to use systemctl, apt-cache, and dpkg to get information about that service. You may find that the service name is a package name. You may have to find which package installed the daemon programs a service has running. You may need to do some research online to learn enough about an unfamiliar package to know if it needs to be on your system.
1. Check which ports are listening for connection or have outbound connections established. `netstat` or `ss` are good tools for this.
```bash
sudo netstat -tulpn
sudo netstat -tupn
```
1. If there are listening ports or outbound connections that you are not expecting based on the services you expect to be running, you could start investigating based on the process that has the port or connection open.
1. Whether you identify a process of interest through a service investigation or a connection investigation, the simple process name may not be very helpful in identifying the service it came from. Either type of investigation will give a process ID (PID). You can use `ps -c PID` to get more info on a running process. You can use dpkg to find out if a process came from a package. If it did, you can used debsums to verify that the program file itself is legitimate and not a rogue. If it is legitimate, then you can use the normal decision process for where you should have that software installed and running. Perform this activity for the service listening on port tcp/25.
```
sudo netstat -tlpn
sudo ss -tlpn
ps -c PID-of-process-listening-on-port-tcp-port-25
dpkg -S pathname-of-process-command
debsums process-command-package | grep pathname-of-process-command
```
Between netstat and ss, which provides more useful output about listening services?
1. Run systemd-analyze security in both summary mode, and specifically for a service to see what it gives you.
```bash
systemd-analyze security
systemd-analyze security hddtemp
```
1. Do you think the systemd-analyze security tool is helpful?

## User Accounts
Many times, user accounts exist which were automatically created, but are not needed. Unwatched accounts are a target for crackers. Accounts which own nothing in the filesystem, and have no running processes are usually either end-user accounts, application accounts, historical accounts, or reference accounts.

1. Identify accounts on the system that have shell access
1. Identify accounts on the system that own no files
1. Identify accounts that have no running processes
1. Accounts which do not appear have a legitimate reason to be on your system should be researched
   * Review https://www.debian.org/doc/manuals/securing-debian-manual/index.en.html and in particular this section: https://www.debian.org/doc/manuals/securing-debian-manual/ch12.en.html#faq-os-users to learn why accounts might exist but not own files
   * Review https://help.ubuntu.com/lts/serverguide/user-management.html for guidance regarding user account security

## Resource Limits
This example of setting resource limits sets limits on interactive system users. As such, it requires the limits to be set at login, and use the PAM library to do it.

1. Review the commented example settings in **/etc/security/limits.conf**
1. Add a limit of 2 logins for the student user
1. Start multiple remote session in multiple terminal windows and verify you cannot login more than twice on the student account simultaneously

## Lynis
Lynis is a tool which can be used for system examination, but is also very useful for hardening activities. Along with identifying things that are not in a typical state, it can make many recommendations regarding insecure configurations. This can be helpful when you have a system running software you may not be familiar with. If you did not already install and update Lynis in the previous lab, follow the steps in this lab to install, update, and run Lynis in this lab. A current version of Lynis running properly and using it to fix at least one thing is part of the mark for this lab.

1. Add the [lynis community repo](https://packages.cisofy.com/community/#debian-ubuntu) to your apt configuration.
1. Run `apt update` and install lynis to ensure you have the latest version. If you already had lynis installed, do `apt upgrade` instead of install.
1. Run lynis in system audit mode.
```bash
wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add -
sudo apt install apt-transport-https
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99disable-translations
echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
sudo apt update
sudo apt install lynis
sudo lynis audit system
```
1. How many suggestions did it give you? Review the warnings.
1. Choose one thing from the list of issues it shows that is related to access security and modify your configuration to eliminate or mitigate the exposure.
1. Re-run lynis and verify it no longer complains about the fixed issue.

## Grading
There are marks for several of the activities in this lab. To get full marks, include all of the following in your submitted PDF. Submit only one PDF file. Other formats will not be marked. Your PDF file can contain both text and images, as appropriate, but the submission must be a single PDF report.

1. Leave your VM running long enough to receive an email from unattended-upgrades. Include a screenshot of the email. You can use the mailx tool to read email for a screenshot.
1. In the section on investigating running services, do the investigation for the service listening on port tcp/25. Use netstat to find the process, ps to find the executable, dpkg to find the package, and debsums to validate the executable is legitimate. Include screenshots showing this process on your system.
1. Identify a list of the accounts on your system that do not own any files. Note that your system may be slightly different from another student's in this lab, depending on what labwork each of you has done up to this point. Include screenshots showing how you found the accounts and which ones are in your list.
1. Include your hosts.allow file showing the rule for denying ssh from one of your other VMs.
1. Include a screenshot showing what was displayed when you tried to exceed the 2 login limit.
1. Include one screenshot showing the the version of lynis your have and a warning from lynis for a specific item you can fix, and one screenshot showing the subsequent output showing it is no longer a concern after you have fixed it.
