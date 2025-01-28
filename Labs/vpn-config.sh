#!/bin/bash
#

#####################################
# define functions for error messages
#####################################
# This function will send an error message to stderr
# Usage:
#   error-message ["some text to print to stderr"]
#
function error-message {
  local prog
  prog=`basename $0`
  echo "${prog}: ${1:-Unknown Error - a moose bit my sister once...}" >&2
}

# This function will send a message to stderr and exit with a failure status
# Usage:
#   error-exit ["some text to print" [exit-status]]
#
function error-exit {
  error-message "$1"
  exit "${2:-1}"
}

#####################################
# end of functions for error messages
#####################################

###########################################################################################
# process cmdline, see if we are setting up the server or creating the files for the client
###########################################################################################
# set a default ip address for the server as 172.16.5.2, specifically for the F20 class
srvip=172.16.5.2
# delete var is undefined to prevent deleting existing certs and keys unintentionally

while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      echo "
$(basename $0) [-h] [-n] [-a serverip] -s servername
$(basename $0) [-h] [-n] [-a serverip] -c clientname servername
Options:
-h                        gives help
-d                        deletes an existing key and certificate if one is already there before making a new one
-s servername             to create the files for a vpn server
-c clientname servername  to create the files for a client for a vpn server
-a serverip               to assign an ip address for the vpn server

"
      ;;
    -s)
      srvname="$2"
      [ -n "$srvname" ] || (echo "need the servername for the -s option, try -h for help";exit 1)
      shift
      ;;
    -c)
      clntname="$2"
      srvname="$3"
      [ -n "$clntname" -o -n "$srvname" ] || (echo "need the clientname and servername for the -c option, try -h for help";exit 1)
      shift 2
      ;;
    -a)
      srvip="$2"
      [ -n "$srvip" ] || (echo "need the ip address when using the -a option, try -h for help";exit 1)
      ;;
    -d)
      delete="yes"
      ;;
    *)
      echo "bad command, try -h for help"
      ;;
  esac
  shift
done

########################
# end of process cmdline
########################

#############################################################################################
# make sure we have root and the openvpn and easy-rsa software installed with easy-rsa set up
#############################################################################################

# root check
[ $(id -u) != "0" ] && error-exit "need root to use this script, use sudo perhaps?"
if [ ! -x /usr/sbin/openvpn ]; then
    apt update || error-exit "apt update failed, are you online?"
    # Install openvpn and easy-rsa if necessary
    apt install openvpn || error-exit "apt install openvpn failed, is your disk full?"
fi
# install easy-rsa if necessary and make the CA dir
if [ ! -x /etc/openvpn/easy-rsa/easyrsa -o ! -x /usr/sbin/openvpn ]; then
    apt update || error-exit "apt update failed, are you online?"
    # Install openvpn and easy-rsa if necessary
    apt install easy-rsa || error-exit "apt install easy-rsa failed, is your disk full?"
    # Then make the CA dir
    make-cadir /etc/openvpn/easy-rsa || error-exit "Failed to make-cadir /etc/openvpn/easy-rsa, does it already exist?"
fi
# make the default pki for the default CA if necessary
if [ ! -d /etc/openvpn/easy-rsa/pki ]; then
    cd /etc/openvpn/easy-rsa
    ./easyrsa init-pki || error-exit "Failed to init-pki, does /etc/openvpn/easy-rsa/pki already exist?"
    ./easyrsa build-ca || error-exit "Failed to build-ca, seems like a bad thing"
    # make sure the ca.crt is readable
    chmod 644 pki/ca.crt
fi

if [ -n "$srvname" -a -z "$clntname" ]; then
    # make the config files we need for our vpn service and put them in a safe place
    #    a private directory we make under /etc/openvpn to keep our config files safe
    #    a server key and cert that we can make with our existing private CA
    #    a diffie-hellman parameter file for the vpn connection key exchange
    #    our server needs to know the name we are going to be using for our vpnserver, put it in the hosts file to keep life simple

    ############################################################
    # create a secure place for our configuration and data files
    ############################################################
    cd /etc/openvpn

    #################################################################################
    # use existing CA to create a key and cert for our vpn service
    #################################################################################
    # easyrsa script expects us to be in the easyrsa directory
    cd easy-rsa
    # If the delete var exists, remove the old key and cert files and links before making the new ones
    [ -v delete ] && [ -f pki/issued/$srvname.crt ] && ( rm $srvname.key $srvname.crt pki/issued/$srvname.crt pki/private/$srvname.key pki/reqs/$srvname.req )
    # build a new key and cert for our vpn service, with read perms on the crt
    # don't make new ones if we already have a cert
    [ -f pki/issued/$srvname.crt ] || (./easyrsa build-server-full $srvname && echo "Made $srvname certificate and key")

    #########################################################################################
    # go to the private vpn config directory and make all the files we need for a vpn service
    ###################################################################
    # go to the openvpn configdata directory to setup the files we need
    ###################################################################
    cd ..
    # make links to the key and cert we just made to the protected vpn config data directory we made previously
    [ -f $srvname.crt ] || (ln easy-rsa/pki/issued/$srvname.crt && chmod 644 easy-rsa/pki/issued/$srvname.crt && echo "Linked $srvname.crt file")
    [ -f $srvname.key ] || (ln easy-rsa/pki/private/$srvname.key && chmod 600 easy-rsa/pki/private/$srvname.key && echo "Linked $srvname.key file")
    # make our diffie-hellman parameters to use when connecting to this vpn service, put the file in the protected config data directory
    [ -f $srvname-dh2048.pem ] || (openssl dhparam -out $srvname-dh2048.pem 2048 && chmod 600 $srvname-dh2048.pem && echo "Made DH params file")
    # create a tls-auth key to mitigate DOS attacks
    [ -f $srvname-ta.key ] || (openvpn --genkey secret $srvname-ta.key && chmod 600 $srvname-ta.key && echo "Made tls-auth key")
    # Link the VPN server's CA certificate, so we know which ca.crt belongs with this VPN server
    [ -f $srvname-ca.crt ] || (ln easy-rsa/pki/ca.crt $srvname-ca.crt && chmod 644 $srvname-ca.crt && echo "Made link to server's ca.crt file")

    ###########################################
    # creates and customize our vpn config file
    ###########################################
    # start with the default server.conf
    # need to make some changes from the default for our lab to match the config data files we just made
    # change
    #   ;local a.b.c.d       ->>   local 172.16.5.2
    #   ca ca.crt            ->>   ca /etc/ssl/certs/ca.pem
    #   cert server.crt      ->>   ca vpn-configfiles/nets1028-vpnserver.crt
    #   key server.key       ->>   ca vpn-configfiles/nets1028-vpnserver.key
    #   dh dh2048.pem        ->>   dh vpn-configfiles/nets1028-vpnserver-dh2048.pem
    #   tls-auth ta.key 0    ->>   tls-auth vpn-configfiles/nets1028-vpnserver-ta.key 0
    [ -f $srvname.conf ] || (sed -e "s,;local a.b.c.d,local $srvname," \
        -e "s,ca ca.crt,ca $srvname-ca.crt," \
        -e "s,cert server.crt,cert $srvname.crt," \
        -e "s,key server.key,key $srvname.key," \
        -e "s,dh dh2048.pem,dh $srvname-dh2048.pem," \
        -e "s,tls-auth ta.key,tls-auth $srvname-ta.key," \
            /usr/share/doc/openvpn/examples/sample-config-files/server.conf > $srvname.conf && chmod 600 $srvname.conf && echo "Made $srvname.conf")
    # done edits on service config file
    # Make a tarfile bundle of the vpn server config files, in case we aren't setting up the vpn service on this machine
    tar czf $srvname-vpnfiles.tgz $srvname.conf $srvname-ca.crt $srvname.crt $srvname.key $srvname-ta.key $srvname-dh2048.pem && echo "Made config files bundle $(pwd)/$srvname-vpnfiles.tgz"

    ##############################################################
    # ensure our server hostname<->address is known on this system
    ##############################################################
    # make sure our vpn service hostname has a valid ip address on this server
    getent hosts $srvname >/dev/null || (echo "$srvip $srvname" >> /etc/hosts && echo "Updated hosts file to have $srvname --- $srvip")

    ########################################################################
    # turn on ip forwarding, if we are using a tap in the server config file
    ########################################################################
    if [ `grep -q '^tap' $srvname.conf` ]; then
      grep -w -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || (sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf && echo "Enabled net.ipv4.ip_forward in sysctl.conf")
      sysctl net.ipv4.ip_forward=1 && echo "Turned on net.ipv4.ip_forward in running kernel"
    fi
    
    #####################
    # end of server setup
    #####################
    
    # Advise the user on next steps
    echo "Then start the openvpn service for $srvname when you are ready"
    echo "Then build the client files for each client"
    
elif [ -n "$srvname" -a -n "$clntname" ]; then

    ####################################
    # begin client config files creation
    ####################################
    
    #################################################################################
    # use existing CA to create a key and cert for our vpn client
    #################################################################################
    # easyrsa script expects us to be in the easyrsa directory
    cd /etc/openvpn/easy-rsa
    # If the delete var exists, remove the old key and cert files and links before making the new ones
    [ -v delete ] && [ -f pki/issued/$clntname.crt ] && ( rm $clntname.key $clntname.crt pki/issued/$clntname.crt pki/private/$clntname.key pki/reqs/$clntname.req )

    # build a new key and cert for our vpn service and ensure the cert has read perms
    # don't make new ones if we already have a cert
    [ -f pki/issued/$clntname.crt ] || (./easyrsa build-client-full $clntname && chmod 644 pki/issued/$clntname.crt && echo "Made client keys and certificate")
    
    #################################################
    # create and customize our vpn client config file
    #################################################
    cd ..
    [ -f $clntname.conf ] || (sed -e "s/my-server-1/$srvname/" -e "s,ca ca.crt,ca $srvname-ca.crt," -e "s,cert client.crt,cert $clntname.crt," -e "s,key client.key,key $clntname.key," -e "s,tls-auth ta.key,tls-auth $srvname-ta.key,"< /usr/share/doc/openvpn/examples/sample-config-files/client.conf > $clntname.conf && chmod 600 $clntname.conf && echo "Made client.conf file")
    [ -f $srvname-ca.crt ] || (ln easy-rsa/pki/ca.crt $srvname-ca.crt && chmod 644 $srvname-ca.crt && echo "Linked ca.crt file")
    [ -f $clntname.crt ] || (ln easy-rsa/pki/issued/$clntname.crt && chmod 644 easy-rsa/pki/issued/$clntname.crt && echo "Linked client.crt file")
    [ -f $clntname.key ] || (ln easy-rsa/pki/private/$clntname.key && chmod 600 easy-rsa/pki/issued/$clntname.key && echo "Linked client.key file")
    [ -f $srvname-ta.key ] || error-exit "Server's ta.key file missing from $(pwd), failed"
    tar czf $clntname-vpnfiles.tgz $clntname.conf $srvname-ca.crt $clntname.crt $clntname.key $srvname-ta.key && rm $clntname.crt $clntname.key $clntname.conf && echo "Made config files bundle $(pwd)/$clntname-vpnfiles.tgz"
    # we now have $clntname.conf, ca.pem, $clntname.crt, $clntname.key, $srvname-ta.key for our client in a tarfile bundle
    # ready for transfer to the client using scp
    
    # Advise the user on next steps
    echo "Use scp or something similar to get the $(pwd)/$clntname-vpnfiles.tgz file onto the vpn client"
    echo "Extract it to the /etc/openvpn directory on the client"
    echo "Then start the openvpn service for $clntname on the client"
    
    ##################################
    # end client config files creation
    ##################################
else
    echo "Must be making client files or server files, no default action exists"
    exit 1
fi
