# Lab 08 Virtual Private Networking
This unit provides an introduction on how to setup VPNs on Linux systems.

## Create a VPN service for a TLS VPN on the Lab Linux VM
In this step you will install and start openvpn service on our lab VM. Use the script I wrote for you [openvpn server setup for this lab](https://zonzorp.github.io/NETS1028/Labs/vpn-config.sh) which is based on instructions found in the [Ubuntu LTS server docs](https://ubuntu.com/server/docs/service-openvpn).

Retrieve and run the script with the server option first to setup your vpn server with openvpn. It is designed to be run on the lab VM I provided for this course.

1. Retrieve the script from the course github website and make it executable
```bash
wget -O ~/vpn-config.sh https://zonzorp.github.io/NETS1028/Labs/vpn-config.sh
chmod +x vpn-config.sh
```

1. Run the script to set up the vpn service for the hostname nets1028-vpnserver on it 172.16.5.2 address
```bash
sudo ./vpn-config.sh -s nets1028-vpnserver
```

1. Start the vpn service running and allow the vpn port through the firewall
```bash
sudo systemctl start openvpn@nets1028-vpnserver
sudo ufw allow 1194/udp
```

1. If there is a password on the private key, you need to use systemd's messed up method of supplying the password - *screenshot*
```bash
sudo systemd-tty-ask-password-agent --query
```

1. Verify the service is running without errors: - *screenshot*
```bash
systemctl status openvpn@nets1028-vpnserver
sudo cat /var/log/openvpn/openvpn-status.log
```

1. Create a tarfile containing the bundle of files for the vpn client to use
```bash
sudo ./vpn-config.sh -c nets1028-vpnclient nets1028-vpnserver
```

## Create a vpn connection to that VPN server
Do these steps on the Linux backups server VM created in a previous lab. We will use it as our vpn client to save creating another VM.

1. Install the openvpn package
```bash
sudo apt update
sudo apt install openvpn
```

1. Retrieve the config file bundle for the client from the vpn server
```bash
scp student@vpn-server-ip-address:/etc/openvpn/nets1028-vpnclient-vpnfiles.tgz .
```

1. Install the config files where openvpn expects them to be and remove the tarfile
```bash
sudo tar xf nets1028-vpnclient-vpnfiles.tgz -C /etc/openvpn
rm nets1028-vpnclient-vpnfiles.tgz
```

1. Make sure the vpn client can resolve the hostname for the vpnserver by adding nets1028-vpnserver with address 172.16.5.2 to your /etc/hosts file on the backups server
```bash
sudo vi /etc/hosts
```

1. Add a route from the backups server to the private network 172.16.5.0/24 via the lab VM
```bash
sudo ip r add to 172.16.5.0/24 via lab-vm-ip-address
```

1. Verify that the backups server can now reach the private address for our vpn service on our lab VM
```bash
ping -c 3 nets1028-vpnserver
```

1. Start the client vpn running and give the password for the client's private key
```bash
sudo systemctl start openvpn@nets1028-vpnclient
```

1. If there is a password on the private key, you need to use systemd's messed up method of supplying the password - *screenshot*
```bash
sudo systemd-tty-ask-password-agent --query
```

1. Verify the service is running without errors: - *screenshot*
```bash
systemctl status openvpn@nets1028-vpnclient
sudo cat /var/log/openvpn/openvpn-status.log
```

## Grading
Submit one PDF and only one PDF containing screenshots showing the work you did. Everywhere there is a screenshot marker in the instructions above, you must capture enough to show the command(s) you ran and the results of running it/them.
