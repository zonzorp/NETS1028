## Practice Exercise: Setting Up Remote Access with SSH Keys

### Objective:
To establish secure remote access to a server using SSH keys.

### Instructions:

#### Generate SSH Key Pair:
Open a terminal.
Use the following command to generate an SSH key pair:
```bash
ssh-keygen -f ~/.ssh/id_rsa -N ""
```
This will create an rsa 2048 bit keypair with unencrypted private key file in ```~/.ssh/id_rsa```.

#### Copy the Public Key to the Remote Server:
Use the following command to copy the public key to a remote server.
Replace REMOTE_SERVER_IP with the actual IP address or hostname of the remote server.
```bash
ssh-copy-id username@REMOTE_SERVER_IP
```
The password for the remote server will have to be given to complete the copy.

#### Verify SSH Key Authentication:
Attempt to SSH into the remote server without entering a password:
```bash
ssh username@REMOTE_SERVER_IP
```

#### SFA using keys: Disable Password Authentication:
On the remote server, open the SSH configuration file in a text editor (e.g., nano or vim).
```bash
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
```

#### Restart the SSH service:
```bash
sudo service ssh restart
```

#### Attempt SSH Login After Password Authentication is Disabled:
Verify logging into the remote server still works by logging into it with ssh again.

### Notes:

This exercise assumes that the machine used to open the terminal in step 1 can communicate on port 22 with the remote machine.
Replace username with your actual username on the remote server.
This exercise assumes the user account being used on the remote server has sudo privileges on the remote server.

## Important:

Always follow security best practices. Do not disable password authentication unless you are certain about the security implications and have alternative secure authentication methods in place.
Keep your private key secure and do not share it with others.

