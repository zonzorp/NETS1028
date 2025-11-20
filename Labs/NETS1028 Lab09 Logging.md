# Lab 09 Logging and Monitoring
This unit provides an introduction on how to configure logging and monitoring software on Linux systems. Unless otherwise specfied, all activities in this lab are to be run on the main lab VM provided at the start of the semester.

## Monitoring Tools

### ss
The ss tool is used primarily to view the status of network communication endpoints. It can be used to view active connections as well as listening or closing endpoints. The next few steps are intended to give you some practice running ss to examine your network connections. Common options are introduced. For each, ask your if yoou understand what it is showing you and whether anything that your machine is doing on the network is a surprise to you.
1. Use ss to show the current active network connections on your VM.
```bash
ss -f inet
```
1. Run the same command, but show the results using numbers instead of names which can be helpful when name services are not necessarily reliable.
```  bash
ss -f inet -n
```
1. Try viewing the listening sockets.
```  bash
ss -f inet -l
```
1. Try viewing them including information about what is using them or providing them.
```bash
ss -f inet -lpn
```
1. Try that same command but with sudo.
1. Review the options for the ss command ```man ss``` to get a feel for other ways you can use this tool.

## Logging Tools
### rsyslog
1. Review the rsyslog.conf and if there are any, the rsyslog.d/*.conf config files in order to see what the default syslog configuration includes
```bash
sudo more /etc/rsyslog.conf /etc/rsyslog.d/*.conf
```
1. Compare the kernel ring buffer (e.g. dmesg) to the kernel messages log file to see if the log file is up to date with the in-memory kernel log
   * in one terminal window: `sudo dmesg|tail -20`
   * in another terminal window: `sudo tail -20 /var/log/kern.log`
1. Can you figure out your sshd access history from the log files? *see what you can find in the /var/log/auth.log file*

### Logrotate
1. Use [webmin](https://pc20022725:10000) to examine the logrotate configuration of your main lab VM. webmin is a webapp system management tool running on port 10000 on the main lab VM and can be accessed using a browser and logging in with a Linux account that has sudo privileges.
1. Can you manage logrotate from [cockpit](https://pc20022725:9090) on that machine? cockpit is a webapp system management tool running on port 9090 on the main lab VM and can be accessed using a browser and logging in with a Linux account that has sudo privileges.

### Logwatch
1. All of the commands in this section of the lab require root, so start a root shell
```bash
sudo bash
```
1. Install logwatch and make the cache directory which the install script doesn't make
```bash
apt update ; apt install logwatch ; mkdir /var/cache/logwatch
```
1. Make an override config file for any of the default ones you want to modify
```bash
cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
```
1. Logwatch has a number of useful options for us to try
```bash
logwatch --range all
logwatch --range 'since last week'
logwatch --logfile secure --logfile http --range all --detail high
```
1. Logwatch can be added to cron easily, some package builds create /etc/cron.daily/00logwatch automatically for you which is a script instead of just a command line to run at specific times - current installs for Ubuntu 20.04 do this automatically and you **do not need to do this for our lab*.
```bash
echo "59 23 * * * logwatch -range 'since yesterday' --format html --output mail" | crontab -
crontab -l
```
1. To preserve us from ourselves, leave the root shell we used for this section of the lab
```bash
exit
```

## Grading
This lab is for practice to reinforce learning. There are no marks for it, and there is nothing to hand in.
