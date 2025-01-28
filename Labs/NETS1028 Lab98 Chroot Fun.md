# Fun With chroot
This is a practice lab. It is not graded. It is a jumping off point for exploring chroot jails.

## chroot Basics
The chroot command can be used to set an existing directory as the visible root for a process. All child processes of that process will inherit that chroot, confining them all to the specific directory tree. For anything to actually work under chroot, all the file resources that the processes running under the chroot will need must be present in that directory tree.

### A tiny playspace for bash
We will create a chroot space to run bash in where the ls command works, the tree command works, and bash builtin commands work, but nothing else is accessible.
1. Create a space to play in.
```bash
mkdir ~/playspace
```
1. Put bash into the playspace so the process can access the executable file to get the code to run. bash lives in /bin, so we need to replicate /bin with bash in it under the playspace directory.
```bash
mkdir ~/playspace/bin
cp /bin/{ls,bash,tree} ~/playspace/bin
```
1. Oure programs are dynamically linked executables, so they will need the libraries they are linked with in order to run. Identify those libraries with the ldd command and replicate them with their locations under playspace.
```bash
ldd ~/playspace/bin/{bash,ls,tree}
tar chf - /lib/x86_64-linux-gnu/{libtinfo.so.5,libdl.so.2,libc.so.6,libselinux.so.1,libpcre.so.3,libpthread.so.0} /lib64/ld-linux-x86-64.so.2 |
    tar -C  ~/playspace/ -xf -
```
1. Now we can use sudo to execute a chrooted process in our playspace directory.
```bash
sudo chroot ~/playspace/ /bin/bash
```

You are now in a shell that thinks the entire system consists only of what is under our playspace directory. You will notice you don't have a custom prompt. That is because it would have come from bash environment files on bash process startup, but we didn't provide those files in our jail. You can play with bash, ls, and tree (e.g. `tree /`) but you will find it rather limited. Use `exit` when you are tired of being in jail.

## chroot for services
Some service programs are built with the ability to use chroot to limit the potential for misuse that can be incurred by users of the service. For this example, we will examine vsftpd, the Very Secure File Transfer Protocol daemon. It provides ftp services. It can allow local Linux user accounts to log into the ftp service using their Linux account username and password. Those users can then view, retrieve and upload files through ftp with the same access they would have when at the shell prompt. The vsftpd daemon has the ability to create a chrooted connection for these users, so that they can only work with files in their own home directory while connected to the ftp service.
1. Connect to your vsftpd to see what the default access looks like for a local user.
```bash
ftp localhost
*login as user student*
ls /
bye
```
1. Note that you saw the root directory listing for the entire system.
1. Use vi or nano to view the `/etc/vsftpd.conf` file on the supplied VM. Look for the option `chroot_local_user`.
```bash
vi /etc/vsftpd.conf
```
1. Note the choice to use this capability only for specific users who are on a list (or not on the list depending on how you set the `chroot_local_user` option) you construct and place in an auxiliary file. Also note that this file is world-readable. Do you think that is a good thing?
1. Try turning on the basic option to chroot local users, save the file, and restart vsftpd.
```bash
sudo vi /etc/vsftpd.conf
systemctl restart vsftpd
```
1. Try connecting to the student account with ftp again, like in the first step.
1. Note that ftp will not allow the chrooted home directory for the user to be writable. That would allow someone to upload whatever environment they wanted into the chrooted space. Exit that ftp session with the `bye` command. Change the user `alice`'s home directory to be read-only, and login to the ftp service as user `alice` (her password is `bob`). See what she now sees for a root directory.
```bash
sudo chmod 555 ~alice
ftp localhost
*login as alice with password bob*
ls /
bye
```
1. Note that she only sees her home directory. Also note that her user name and group don't show up in the listing because there is no copy of /etc/passwd in the chroot jail for the userid and groupid that own the file to be looked up in.
1. Remove the chroot setting from your vsftpd.conf, restart the daemon, and give alice back permission to put files in her own home directory.
```bash
sudo vi /etc/vsftpd.conf
systemctl restart vsftpd
sudo chmod 755 ~alice
```

So we can see that chroot for vsftpd provides a jail capability, but it has side effects, so it isn't something we would just turn on for all users without considering the impacts. This is true for more or less all services that have chroot capabilities.
