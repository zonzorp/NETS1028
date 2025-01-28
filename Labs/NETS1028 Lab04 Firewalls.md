# Lab 04 Firewalls and filters
This unit provides basic coverage of the tools and techniques for firewalling and filtering traffic on a Linux system.

## Iptables Basics
This activity will familiarize you with the basics of creating rules for iptables chains and verifying whether your rules do what you wanted them to do.

1. connect to your server's **ssh** service with a terminal window or with putty
1. Log into the **student** account
1. Since we are using a prebuilt VM that has ufw configured, save the existing ufw configuration **ONLY DO THIS ONCE, EVEN IF YOU RESTART THE LAB**
```bash
sudo ufw show added >~/`date +%Y%m%d%H%M-ufw-rules-saved.$$`
```
1. Clear out the leftovers from iptables
```bash
sudo ufw reset
sudo iptables -F
sudo iptables -X
```
1. Verify you can connect to your VM using a web browser
   * use the ip address of your ens33 interface (`ip a s ens33`)
   * access the cockpit service at `http://W.X.Y.Z:9090` (W.X.Y.Z should be your VM's ens33 IP address)
   * login to the cockpit service with the student login and password that used for ssh
1. Create a set of iptables rules to
   * allow any traffic on the loopback interface
   * allow **ssh** inbound traffic on your **ens33** interface
   * log and count any input tcp traffic that is not destined for your **ssh** service
   * set the **INPUT** and **OUTPUT** policy to DROP
   ```bash
   iptables -A INPUT -i lo -j ACCEPT
   iptables -A OUTPUT -o lo -j ACCEPT
   iptables -A INPUT -i ens33 -p tcp --dport ssh -j ACCEPT
   iptables -A INPUT -i ens33 -p tcp \! --dport ssh -c 0 0 -j LOG --log-prefix "INPUT DENIED: "
   iptables -P INPUT DROP
   iptables -P OUTPUT DROP
   ```
1. Is your cockpit web page still updating?
1. Does your ssh session still work?
1. See what is getting logged for your iptables rules
```bash
sudo grep DENIED /var/log/kern.log
```
1. View your iptables rules using the -L and -S options
```bash
sudo iptables -L
sudo iptables -S
```
1. Which one is more useful to see your rules?
1. Reboot your VM
1. View your iptables rules again. Did the reboot change anything?

## Iptables Persistence
1. Reinstall the iptables rules from the first part of the lab and verify they are present
   ```bash
   iptables -A INPUT -i lo -j ACCEPT
   iptables -A OUTPUT -o lo -j ACCEPT
   iptables -A INPUT -i ens33 -p tcp --dport ssh -j ACCEPT
   iptables -A INPUT -i ens33 -p tcp \! --dport ssh -c 0 0 -j LOG --log-prefix "INPUT DENIED: "
   iptables -P INPUT DROP
   iptables -P OUTPUT DROP
   iptables -L
   ```
1. Install the iptables-persistent package, without agreeing to save the rules during installation of the package
```bash
sudo apt install iptables-persistent
```
1. Save your IPV4 rules with the iptables-save command
```bash
sudo iptables-save |tee /etc/iptables/rules.v4
```
1. Examine the contents of **/etc/iptables/rules.v4** and compare it to the output of `iptables-save`
1. Reboot and verify your rules are automatically reinstalled
```bash
reboot
```
1. Remove the iptables-persistent package
```bash
sudo apt remove iptables-persistent
```
1. Reboot and check if your rules are still getting installed at boot
```bash
reboot
```

## Kernel Tuning with sysctl
1. Run `sysctl -a` to get an idea of the kernel parameters currently set up on your system
1. What are the security implications of being able to retrieve this type of information as an ordinary user?
1. https://www.kernel.org/doc/Documentation/sysctl/vm.txt has excellent sysctl documentation for kernel version 2.6 (still in use in production systems and embedded systems)
   * Find the **swappiness** parameter in that document to see what it can do for you
   * Check out the wikipedia article for more info

Performance tuning also affects resiliency, example references on tuning for performance include:
http://wiki.mikejung.biz/Ubuntu_Performance_Tuning https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/ https://lonesysadmin.net/2013/12/19/account-bandwidth-delay-product-larger-network-buffers/

## Iptstate
1. Install iptstate package
```bash
sudo apt install iptstate
```
1. Clear your iptables rules and add back the rules we have been using, but with connection tracking turned on for new connections to the **ssh** service
```bash
sudo ufw reset
sudo iptables -F
sudo iptables -X
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -i ens33 -p tcp --dport ssh -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A INPUT -i ens33 -p tcp \! --dport ssh -c 0 0 -j LOG --log-prefix "INPUT DENIED: "
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
```
1. Run iptstate and observe the various connections being tracked by iptables
```bash
sudo iptstate -f
```
1. Use iptables -L -v to see the packet and byte counts being seen by the various rules you have in place
```bash
sudo iptables -L -v
```

## UFW
UFW is already installed on the lab VM.
1. Clear out the iptables rules we currently have, as well as any leftover ufw rules
```bash
sudo ufw reset
sudo iptables -F
sudo iptables -X
```
1. Use ufw to allow ssh traffic
```bash
sudo ufw allow ssh
```
1. Check your status with ufw, enable it, recheck your status
```bash
sudo ufw status
sudo ufw enable
sudo ufw status
```
1. Run iptables -L -v with the ufw firewall tool in enabled state
```bash
sudo iptables -L -v
```
1. Disable the ufw firewall tool and see what is left behind in your live iptables
```bash
sudo ufw disable
sudo ufw status
sudo iptables -L
```
1. Clear out your tables for the next exercise
```bash
sudo ufw reset
sudo iptables -F
sudo iptables -X
```

## Ipkungfu
1. Install the ipkungfu package and check its state after installation
```bash
sudo apt install ipkungfu
sudo ipkungfu -c
```
1. Note the configuration files in /etc/ipkungfu
1. Modify ipkungfu.conf to set GATEWAY=0, DISALLOW_PRIVATE=0
```bash
sudo vi /etc/ipkungfu/ipkungfu.conf
```
1. Modify services.conf to ACCEPT ftp and ssh traffic
```bash
sudo vi /etc/ipkungfu/services.conf
```
1. Run ipkungfu --show-vars to see your current configuration with ipkungfu’s guesses and correct any settings you can see are not right for your VM
```bash
sudo ipkungfu --show-vars
```
1. Run ipkungfu -t to test and install your new configuration
```bash
sudo ipkungfu -t
```
1. Use iptables -L to see the new iptables configuration
```bash
sudo iptables -L
```
1. Check /etc/default/ipkungfu to see if it is enabled on system startup (IPKFSTART setting) and make sure it is disabled before doing fail2ban
```bash
sudo cat /etc/default/ipkungfu
```

## Fail2ban
For this activity, you will want to have 2 separate terminals or putty windows running at the same time. Do the steps up to monitoring the log file in the first window, and then switch to the other window to cause the failed logins. Once you do that, the ip address that the failures are coming from will be banned, so be sure your second session isn't coming from the same ip address as your first session.

1. Clear out your tables before starting the exercise
```bash
sudo ufw reset
sudo iptables -F
sudo iptables -X
```
1. Install fail2ban
```bash
sudo apt install fail2ban
```
1. Use fail2ban-client to see the default configuration that is running
```bash
sudo fail2ban-client status
```
1. Check the status of default sshd jail that is installed
```bash
sudo fail2ban-client status sshd
```
1. Start monitoring the fail2ban.log using tail -f to see what the service does for the next steps
```bash
sudo tail -f /var/log/fail2ban.log
```
1. Use a second terminal/putty window to login to your VM from a different machine than your other ssh session, but give the wrong password 6 times in a row while watching the fail2ban log in your other ssh session
1. Once the service bans your ip according to the watched logfile, cancel the logifle monitoring using ^C (ctrl-c) and examine the ban with the following commands in the terminal window that is still working
```bash
fail2ban-client status sshd
fail2ban-client get sshd bantime
```
1. Clear the ban manually
```bash
fail2ban-client set sshd unbanip w.x.y.z
fail2ban-client status sshd
```
1. Verify your second terminal/putty window can connect using ssh again
