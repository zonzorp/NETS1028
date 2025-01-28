#!/bin/bash
# This script does incremental backups to a potentially remote host using rsync
# created by Dennis Simpson
# If you use it as it is without considering what it does or the default settings, then you deserve what you get
# This was created for a the NETS1028 couorse as an example of setting up centralized versioned backups
# Its most glaring shortcoming is the lack of a check for available space before running the backup
# There are other shortcomings which are less significant

# Defaults match the vm config on my macbookpro
HOSTTOBACKUP=$(hostname) # you may want something more descriptive or useful than just the hostname
REMHOST=172.16.253.135 # don't leave this set to this address
REMUSER=root # use a user on your target host, not root
REMBACKUPDIR=/backup # think about where you want your backups on the remote host

function usage {
  prog=$(basename "$0")
  echo "Usage: $prog [-h|--help] [-rh|--remote-host host] [-ru|--remote-user user] [-rd|--remote-backup-directory directory] [-i|--initialize] [-v|--verbose]"
}

# Allow the user to specify backup params
while [ $# -gt 0 ]; do
  case $1 in
  -h | --help)
    usage
    exit
    ;;
  -rh | --remote-host)
    if [ -z "$2" ]; then
      echo "remote host option requires you to specify the remote host name or IP" >&2
      usage >&2
      exit 2
    fi
    REMHOST="$2" # might want some kind of input validation here
    shift
    ;;
  -ru | --remote-user)
    if [ -z "$2" ]; then
      echo "remote user option requires you to specify the remote user name" >&2
      usage >&2
      exit 2
    fi
    REMUSER="$2" # might want some kind of input validation here
    shift
    ;;
  -rd | --remote-backup-directory)
    if [ -z "$2" ]; then
      echo "remote backup directory option requires you to specify the remote directory name" >&2
      usage >&2
      exit 2
    fi
    REMBACKUPDIR="$2" # might want to validate this is a pathname and is not / or some other attempt at vandalism
    shift
    ;;
  -i | --initialize)
    init=1
    ;;
  -v | --verbose)
    verbose=1
    ;;
  esac
  shift
done

# Initializing means creating the remote backup directory, and setting up ssh keys
# To avoid having to enter passwords, create a local key pair using
#        ssh-keygen and put the public key in root's authorized_keys on the remote host
if [ "$init" == 1 ]; then
  if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -q -t rsa -b 2048
  fi
# many servers run sshd in default config which does not permit root login with a password
# to add the public key to them, you will need an out of band method of adding the key
  ssh-copy-id $REMUSER@$REMHOST
  if [ $? != 0 ]; then
    echo "Failed to copy ssh key to remote system. Exiting now." >&2
    exit 1
  fi
  ssh $REMUSER@$REMHOST mkdir -p $REMBACKUPDIR/$HOSTTOBACKUP >&/dev/null
  if [ $? != 0 ]; then
    echo "Failed to make backups directory on remote system. Exiting now." >&2
    exit 1
  fi
fi

# we use the current date and time without seconds to name the backup directory
date=$(date "+%F-%H-%M")
# Let the user know what we are doing
echo "Backing up $HOSTTOBACKUP to $REMBACKUPDIR on $REMHOST as user $REMUSER"
# run the backup and change the current version link to point to the backup just finished
# Add the following type of option if you want things excluded:
#           --exclude={/proc/*,/tmp/*,/run/*,/dev/*,/sys/*,/mnt/*,/lost+found,/media/*,/backup*} \
# Note that this command is designed to backup the root filesystem only.
# If you have multiple filesystems to backup, you need to modify this.
rsync -azxh$verbose --link-dest=$REMBACKUPDIR/$HOSTTOBACKUP/current --delete \
      /* $REMUSER@$REMHOST:$REMBACKUPDIR/$HOSTTOBACKUP/$date
if [ $? == 0 ]; then
  ssh $REMUSER@$REMHOST ln -nsf $REMBACKUPDIR/$HOSTTOBACKUP/$date $REMBACKUPDIR/$HOSTTOBACKUP/current
else
  echo "Backup failed, not changing link for current backup." >&2
fi
