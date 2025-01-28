# Lab 07 Authentication and Access Control
This unit provides an introduction on how to manage Access/Authentication/Authorization software on Linux systems.

## Password Expiry Exercises
1. Use grep to extract the line for the student account from /etc/shadow, examine the parameters for expiration and change
1. Use the passwd command to change the student account to expire in 1 day and warn you for 3 days
1. Use grep again and compare the entry to what it was before the change
1. Log into the student account using ssh in a terminal window and observe the warning message at login regarding your password
1. Change the student account password, then log out of the ssh session and back in again
1. Observe what happened to the password expiration warning
1. Remove the expiration using the passwd command to set the warning and expiration to 0
1. Use grep to confirm that you no longer have expiry on the student account in /etc/shadow
1. Log out of the student ssh session and back in to verify you are no longer told the student password is expiring

## Password Content Exercises
1. Modify your /etc/pam.d/common-password file to enforce a minimum password length of 12 characters and remember 2 passwords
1. Try to change the student password to something shorter than 12 characters, then change it to something longer than 11 characters
1. Try to change it back to what it was before
1. Remove the minlen and remember options from your /etc/pam.d/common-password file and try again to change the student password back to the original one
1. Lock the `dennis` account using `usermod -lock` and verify you can no longer log in to that account - the password on that account is `dennis`
1. Unlock the `dennis` account

## SSH Exercises
1. Create a key pair for the student account to use ssh using `ssh-keygen`
1. Copy the public key to the student account's `~/.ssh/authorized_keys` using `ssh-copy-id student@localhost`
1. Verify you can use ssh to access localhost without entering a password
1. Modify the server’s sshd_config to not allow password logins (i.e. use without-password option, then restart service) and verify you can still access localhost using ssh

## Grading
This lab is not graded; it is only for practice. There is nothing to capture, and nothing to submit.
