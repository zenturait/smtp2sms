#!/bin/bash

#judgement
if [[ -a /etc/supervisor/conf.d/supervisord.conf ]]; then
  exit 0
fi

if [ -z $SMS_APIKEY ] || [ -z $SMS_FROM ]; then
  echo Missing SMS_APIKEY or SMS_FROM
  exit 1
fi

#supervisor
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true

[program:postfix]
command=/opt/postfix.sh

[program:rsyslog]
command=/usr/sbin/rsyslogd -n
EOF

if [ -z "$MAILDOMAIN" ]; then
  export MAILDOMAIN=$(hostname)
fi

############
#  postfix
############
cat >> /opt/postfix.sh <<EOF
#!/bin/bash
service postfix start
tail -f /var/log/mail.log
EOF
chmod +x /opt/postfix.sh
postconf -e myhostname=$MAILDOMAIN
postconf -F '*/*/chroot = n'

############
# SASL SUPPORT FOR CLIENTS
# The following options set parameters needed by Postfix to enable
# Cyrus-SASL support for authentication of mail clients.
############
# /etc/postfix/main.cf
postconf -e smtpd_sasl_auth_enable=yes
postconf -e broken_sasl_auth_clients=yes
postconf -e smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination
# smtpd.conf
cat >> /etc/postfix/sasl/smtpd.conf <<EOF
pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5 NTLM
EOF

# Inject APIkey + SMS Sender

sed -i "s/%SMS_APIKEY%/$SMS_APIKEY/g" /app/smtp2sms.php
sed -i "s/%SMS_FROM%/$SMS_FROM/g" /app/smtp2sms.php

# sasldb2
echo $SMTP_USER | tr , \\n > /tmp/passwd
while IFS=':' read -r _user _pwd; do
  echo $_pwd | saslpasswd2 -p -c -u $MAILDOMAIN $_user
done < /tmp/passwd
chown postfix.sasl /etc/sasldb2

exec $@
