#!/bin/bash

# find suspicious files

files=`find / -type f -executable -exec dpkg -S {} \; |& grep 'no path found' | grep -v /var/lib/dpkg|sed -e 's/^dpkg-query: no path found matching pattern //'`
echo "$#files[@] files found"
echo "Programs not from packages:"
echo "---------------------------"
find / -type f -executable -exec dpkg -S {} \; |& grep 'no path found' | grep -v /var/lib/dpkg|sed -e 's/^dpkg-query: no path found matching pattern //'
echo
echo "Orphans"
echo "-------"
find / -nogroup -ls
find / -nouser -ls
echo
echo "Setuid programs:"
echo "----------------"
find / -type f -perm -4000 -executable -ls 2>/dev/null
echo "Setgid programs:"
echo "----------------"
find / -type f -perm -2000 -executable -ls 2>/dev/null
echo
echo "Executables whose names start with a dot:"
echo "-----------------------------------------"
find / -type f -executable -name '.*' -ls 2>/dev/null
echo
echo "Home directory files not owned by user that owns the home directory holding them"
echo "--------------------------------------------------------------------------------"
for u in /home/*; do
  user=$u:t
  find $u ! -user $user -ls
done
