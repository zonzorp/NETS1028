# Lab 06 Backups and Change Management
In this exercise, we will explore the uses and limitations of various tools for creating backup copies of filesystems. Most tools have tasks they are well suited to, and other tasks they get used for but are not well suited to perform. We will create a data directory to use for evaluating tools, then experiment in detail with the simple file copy command to see what kinds of assumptions and limitations must be accounted for. Then we will use rsync to perform backups that have the features we look for in a live backup system.

## Setup
Begin by running some commands to create a sample data space for us to work in. It will create files owned by multiple users sharing a data space by using group permissions. There are a few directories and different file types in it to simulate actual files you might find on a production server. Simply copy and paste these commands into a shell where you are logged into your Linux VM as student. The last 2 commands will show you what was made. The tree command will show what was made and purports to tell you how much disk space is used by your files. The second runs the du command to tell you how much space is actually used.
```bash
mkdir -p ~/data/{a,b,c,d}
pushd ~/data
dd if=/dev/zero bs=100M count=1|base64 >b/bigfile.txt
dd if=/dev/zero of=d/biggerfile bs=1 count=0 seek=512M
for i in {1..3}; do
ln b/bigfile.txt a/altfile$i.txt
ln -s ../b/bigfile.txt c/lfile$i.txt
mknod d/sock$i p
done
sudo chgrp -R staff .
sudo chown -R bob d
sudo chown -R alice a
sudo chown -R ted c
sudo chmod 2750 ?
popd
sudo tree -push --du ~/data
sudo du -sh ~/data
```

Why is there a difference in the amount of disk space in use between the tree command and the du command? Which one is correct?

## cp
In this section we will examine the standard copy program, `cp`. If you are already familiar with the `cp` commamd, you may already know what it does. This activity tries using it in multiple ways to uncover limitations in the command that affect the usefulness of files backed up this way. We look at this one because it is commonly misused.

1. Copy the data directory that was created by the lab setup. Try the basic `cp` without options to see what happens. You should get an error about copying directories.
```bash
cp ~/data ~/data2
```

1. Next try `cp` with the recursive option. You should get an error about not having permissions to access files from the student account. Check to see what did get copied, and what that looks like. - *screenshot*
```bash
cp -r ~/data ~/data2
tree -push --du ~/data2
du -sh ~/data ~/data2
```

1. Next try running `cp` recursively again, but this time use sudo to solve the permissions problem. Check to see what got created. - *screenshot*
```bash
sudo cp -r ~/data ~/data3
sudo tree -push --du ~/data3
sudo du -sh ~/data ~/data3
```

1. Next try `cp` with the archive option and sudo. Check to see what got created. - *screenshot*
```bash
sudo cp -a ~/data ~/data4
sudo tree -push --du ~/data4
sudo du -sh ~/data ~/data4
```

1. Which of these is a useful way to create a backup of a data directory, if any? - *include this question with your answer in your submission on blackboard*

## Rsync
cp and other tools like it are designed to copy files from one place to another on a single computer. Backups written to remote computers require additional thought. It is particularly valuable to have versioned backups in order to avoid losing your backups to ransomware. Offline backups can also be useful if done correctly.

### Remote backup with rsync
In this example, to keep this lab simple, we will just use rsync with ssh to create versioned backups on a remote backup server from our existing Linux VM using the root account. To use this for protection against ransomware or other system compromises, additional steps would have to be taken and we would not use root access. So the main purpose of this lab activity is to become familiar with remote backups created by rsync.

1. Create a VM to use as a backup server. Install Ubuntu server 20.04LTS, with ssh installed, and add two extra drives during the installation, each 20GB in size. Mount one of them on /backups, and leave the other unallocated.
1. When the new backup server is installed, enable root access using keys for ssh by adding your public key from your existing server VM
   * On the existing Linux VM, create RSA keys for ssh if you don't already have them:
   ```bash
   sudo bash
   cd
   ssh-keygen
   cat ~/.ssh/id_rsa.pub
   exit
   ```
   * On the backup server, install the public key from the previous server VM's root account:
   ```bash
   sudo vi /root/.ssh/authorized_keys
   ```
   * On the existing Linux VM, verify your ssh to root from root works correctly: - *screenshot*
   ```bash
   sudo ssh root@backup-vm-ip id
   ```
   * Do not proceed until this works

1. Run a remote rsync backup from your ubuntu machine to the backup server vm similar to the example from the slide - *screenshot*
```bash
date=$(date '+%F-%H-%M') ; sudo rsync -ah --link-dest=/backups/latest --delete --exclude={/proc/*,/tmp/*,/run/*,/dev/*,/sys/*,/mnt/*,/lost+found,/media/*,/backups,/swap.img} / root@backup-srvr-ip:/backups/$date && sudo ssh root@backup-srvr-ip ln -nsf /backups/$date /backups/latest
```

1. Leave your VMs running for at least 20 minutes so changes can happen to your VM and then rerun the backup to see how much new or changed data got transferred - *screenshot the command and only the first screenful of output*
```bash
date=$(date '+%F-%H-%M') ; sudo rsync -ahv --link-dest=/backups/latest --delete --exclude={/proc/*,/tmp/*,/run/*,/dev/*,/sys/*,/mnt/*,/lost+found,/media/*,/backups} / root@backup-srvr-ip:/backups/$date && sudo ssh root@backup-srvr-ip ln -nsf /backups/$date /backups/latest
```

1. Examine the /backups filesystem on your backup server vm to see what it looks like - *screenshot*
```bash
ls /backups
df -h
du -sh /backups/*/
```

## Remote restore with rsync
To restore a backup, we more less reverse the process and copy files from the backups repository to wherever we want to have them. We can use the rsync program or we can just find and manually copy whatever files we want. Perform the following tasks on the original Linux server VM, not the backup server.

1. Create a staging directory to restore files into
```bash
mkdir ~/restoredfiles
```

1. Restore everything from our most recent home directory backup, use the credentials we used to make the backup to keep the lab simple - *screenshot*
```bash
cd
sudo rsync -av root@backup-srvr-ip:/backups/version-identifier/home/student/ restoredfiles/
```

1. Use the tree command to verify your files were restored to the staging directory.

## Grading
Submit one PDF containing screenshots showing the work you did. Everywhere there is a screenshot marker in the instructions, you must capture enough to show the command you ran and the results of running it. Include the question from the section on the `cp` command with your response.

