# Setting up smarthost through a typical ISP
This extra exercise does not count for marks and is not required. But it is a useful practice for setting up email relaying through an ISP which blocks the SMTP port (most modern ISPs block this and force you send email through their servers). If you have your email server setup like shown in this lab, you can use the following commands to add relaying via an external server. Use the actual name of the mail server you are relaying through instead of `yourispmailserverdomainname` and your ISP-required email login and password instead of `myemailaddress` and `myemailpassword`.
```bash
externalrelayhost=yourispmailserverdomainname
emailaddr='myemailaddress'
emailpass='myemailpassword'
sudo postconf -e "smtp_sasl_auth_enable = yes"
sudo postconf -e "smtp_tls_security_level = encrypt"
sudo postconf -e "smtp_sasl_tls_security_options = noanonymous"
sudo postconf -e "relayhost = [$externalrelayhost]:submission"
sudo postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
echo "[$externalrelayhost]:submission $emailaddr:$emailpass" | sudo tee /etc/postfix/sasl_passwd >/dev/null
sudo postmap hash:sasl_passwd
sudo systemctl restart postfix
```
Your Linux mail server should now be able to send email to any legitimate internet email address, although they cannot send email to your email server without further work on your part. It is still useful for sending yourself email from your Linux system instead of having to log onto the Linux system to read mail sent to root or other users. You can even create an alias for root to forward root mail to your normal email account. You can test this using a command like:
```bash
sudo nano /etc/aliases
sudo newaliases
mail -s "Test message from my server" root <<< "testing...testing"
```

## Further Resources and Reading
Review **http://www.postfix.org/SASL_README.html** for a detailed howto on setting up other scenarios for postfix using either dovecot or cyrus for Simple Authentication and Security Layer.

Review **https://help.ubuntu.com/community/PostfixVirtualMailBoxClamSmtpHowto** for an overview of how to configure multiple email domains on a single postfix/dovecot server.

Review [Postfix SOHO Hints and Tips](http://www.postfix.org/SOHO_README.html) for settings and commands for configuring email servers connected to ISPs that require you to relay mail through servers.
