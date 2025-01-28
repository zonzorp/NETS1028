# Lab 02 System Examination
System Examination involves evaluating whether a computer system or network contains what it is intended to contain and only what it is intended to contain, and is behaving according to expectations. This cannot be done without defining expectations of what it should contain and how it should behave.

## Defining Expectations
Since our VM was not built by us, we would be dependant on receiving expected state documentation from whoever ran it before us. We will take the position that such documentation/policy is non-existent for our system beyond the brief description of the server we saw in Lab 1. So our examination of the system will provide our baseline documentation of the system's current state.

## Evaluating Static State
The content of a system may be divided up in any way that makes sense for your organization. For our purposes, we will ignore hardware since we are using virtual machines, and focus instead on software and data.

### Software
To keep this part manageable in the time we have for the course, we will only focus on software that is installed as a package or group of packages. We will ignore manually installed software that is not managed by the APT package tools.

1. What software is installed, and is it the right software?
   1. Identify installed software, noting non-required software
   1. Check for currency of installed software
   1. Identify security risks of installed software by checking CVEs
1. Is the software's integrity intact?
   1. Install debsums package
   1. Use the debsums command to check the binary and configuration files in the openssh-client package
   1. Use debsums to check if you have any packages installed without checksums
   1. Modify your /etc/ssh/ssh_config file in a trivial way
   1. Does debsums find your change when you rerun it?
   1. Rename your /usr/bin/scp file to /usr/bin/scp.orig
   1. Rerun debsums to see if it tells you about the now-missing scp program
   1. Rename /usr/bin/scp.orig back to /usr/bin/scp
1. What configuration-oriented changes are there?
   1. Identify all package-installed configuration files which are no longer in their default configuration as reported by debsums
   1. Do you have other configuration files that have changed that debsums does not report?
   1. Who can use su/sudo?

### Data
1. Who has what kind of data on the system?
   1. What user accounts exist on the system?
   1. What file types exist in user's files (ones not owned by system accounts)?
1. Are there resource limits?
   1. Are there any quotas in the filesystems?
   1. Are there any resource (CPU/memory) limits on end-user accounts?
1. Are there any "bad" files?
   1. Do any users have world-writable permissions on their files/directories? If so, should they?
   1. Do any users have excessive space usage or hidden files that you would not expect to find?
   1. Do any end-users own setuid or setgid files?
   1. Do any end-users have files that do not belong to them in their home directories or other data spaces that they own?
   1. Are there files owned by system accounts that were not installed as part of packages?
   1. Are there end-user-owned files in any of the system directories such as /, /etc, /bin, /sbin, anywhere under /usr?
   1. Are there dotfiles (hidden files) anywhere but in end users' home directories?

*How is awareness of this state information kept current?*

### State Examination Software
Install and try [Lynis](https://packages.cisofy.com/community/) and [AIDE](https://aide.github.io) for system examination and evaluation.

## Evaluating Dynamic State
1. Explore dynamic state tools you haven't used before that are mentioned in the presentation on slides 9-12
1. Review the contents of your /var/log/auth.log file to see what kind of log entries are in it
1. Try each of the su and sudo methods of getting privileged access to the system, but use wrong passwords
1. Try logging in with ssh using a wrong password
1. Try logging in with ssh using an invalid username
1. Review what got logged for each of the failed access attempts to become familisr with what those entries look like

Review the suggestions at [https://wiki.ubuntu.com/BasicSecurity/DidIJustGetOwned](https://wiki.ubuntu.com/BasicSecurity/DidIJustGetOwned).

## Grading
This lab is intended to familiarize you with the basic tools used to examine any system for security-related purposes. There is nothing to hand in for this lab. The more you do with it, better positioned you will be for the remainder of the INSS program. This is purely a learning reinforcement activity.
