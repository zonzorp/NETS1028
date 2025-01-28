#!/bin/bash

# this script display a list of users in the passwd file who own no files

for user in `cut -d : -f 1 /etc/passwd`; do
find / -ignore_readdir_race -user $user -ls -quit | grep -q $user || echo $user
done
