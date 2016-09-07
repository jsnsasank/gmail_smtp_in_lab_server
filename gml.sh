#!/usr/bin/env bash
########################################################################
# Script Name          : GML.sh
# Author               : Lal Pasha Shaik
# Creation Date        : 12-Dec-2014
# Description          : Configure Mail relay.
########################################################################

# install packages
yum -y install postfix cyrus-sasl-plain mailx

#enable postfix
systemctl restart postfix
systemctl enable postfix

#update main.cf

cp -p /etc/postfix/main.cf /etc/postfix/main.cf.$(date +%F.%H%M)

if ! grep -q "#ORG MAIL" /etc/postfix/main.cf
then
cat >> /etc/postfix/main.cf <<-EOFa
#ORG MAIL
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
EOFa

fi

cat > /etc/postfix/sasl_passwd <<- EOFb
[smtp.gmail.com]:587    <user-name>@gmail.com:<password>
EOFb

#postmap
postmap /etc/postfix/sasl_passwd

# permissions
chown root:postfix /etc/postfix/sasl_passwd*
chmod 640 /etc/postfix/sasl_passwd*

# restart postfix
systemctl reload postfix

# send test mail 
echo "Hello World!" | mail -s "GML TEST" <email-address>