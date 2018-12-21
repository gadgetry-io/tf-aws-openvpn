Content-Type: multipart/mixed; boundary="===============BOUNDARY=="
MIME-Version: 1.0


--===============BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0

#cloud-config

public_hostname=${public_hostname}
admin_user=${admin_user}
admin_pw=${admin_pswd}
license=${license_key}
reroute_gw=${reroute_gw}
reroute_dns=${reroute_dns}
use_google_auth=${use_google_auth}


--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

echo "INSTALL PACKAGE DEPENDENCIES"
apt update -y
apt install -y unzip
apt install -y libwww-perl libdatetime-perl

# INSTALL CLOUDWATCH MONITORING SCRIPTS
echo "INSTALL CLOUDWATCH MONITORING SCRIPTS"
echo "--> DOWNLOAD CLOUDWATCH MONITORING SCRIPTS"
curl "https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip" -o "/root/CloudWatchMonitoringScripts-1.2.1.zip"
echo "--> UNZIP CLOUDWATCH MONITORING SCRIPTS"
unzip "/root/CloudWatchMonitoringScripts-1.2.1.zip" -d /root
rm "/root/CloudWatchMonitoringScripts-1.2.1.zip"
echo "--> SET CRONTAB ENTRY FOR INSTANCE DATA"
crontab -l | { cat; echo "* * * * * /root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --auto-scaling=only --from-cron"; } | crontab -

# INSTALL AWS-CLI
echo "INSTALL AWS-CLI"
echo "--> DOWNLOAD AWSCLI-BUNDLE.zip"
curl -n "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/root/awscli-bundle.zip"
echo "--> UNZIP AWSCLI-BUNDLE.zip"
unzip "/root/awscli-bundle.zip" -d /root
echo "--> INSTALL AWS BINARY"
/root/awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
rm "/root/awscli-bundle.zip"
rm -rf "/root/awscli-bundle"

if [ ${use_ldap} == 1 ]; then
    echo "--> CONFIGURING LDAP"
    # CONFIGURE LDAP AUTH
    echo "CONFIGURE: OPENVPN LDAP AUTHENTICATION"
    echo "--> SET LDAP AUTH"
    /usr/local/openvpn_as/scripts/sacli --key "auth.module.type" --value "ldap" ConfigPut

    # SET LDAP SERVERS
    echo "--> SET LDAP SERVERS"

    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.server.0.host" --value "${ldap_server_1}" ConfigPut
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.server.1.host" --value "${ldap_server_2}" ConfigPut

    # SET LDAP BIND CREDENTIALS
    echo "--> SET LDAP BIND CREDENTIALS"
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.bind_dn" --value "${ldap_bind_dn}" ConfigPut
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.bind_pw" --value "${ldap_bind_pswd}" ConfigPut

    # SET LDAP BASE DN FOR USER SEARCH
    echo "--> SET BASE DN FOR USER SEARCH"
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.users_base_dn" --value "${ldap_base_dn}" ConfigPut

    # SET LDAP USERNAME ATTRIBUTE
    echo "--> SET USERNAME ATTRIBUTE"
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.uname_attr" --value "${ldap_uname_attr}" ConfigPut

    # SET LDAP ADDITIONAL MEMBEROF REQUIREMENT
    echo "--> SET MEMBEROF REQUIREMENT"
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.add_req" --value "${ldap_add_req}" ConfigPut

    # SET LDAP USE SSL
    echo "--> SET LDAP TO USE SSL"
    /usr/local/openvpn_as/scripts/sacli --key "auth.ldap.0.use_ssl" --value "${ldap_use_ssl}" ConfigPut
fi


echo "APPLY FIX FOR WEB UI SLOWNESS"
/usr/local/openvpn_as/scripts/sacli --key vpn.client.client_sockbuf --value 0 ConfigPut
/usr/local/openvpn_as/scripts/sacli --key vpn.server.server_sockbuf_tcp --value 0 ConfigPut
/usr/local/openvpn_as/scripts/sacli --key vpn.server.server_sockbuf_udp --value 0 ConfigPut

if [ ${use_google_auth} == 1 ]; then
  echo "--> USE GOOGLE AUTHENTICATOR"
  # USE GOOGLE AUTHENTICATOR
  /usr/local/openvpn_as/scripts/sacli --key "vpn.server.google_auth.enable" --value "true" ConfigPut
fi

if [ ${use_lets_encrypt} == 1 ]; then

    apt install -y curl libltdl7 python3 python3-pip python software-properties-common
    add-apt-repository -y ppa:certbot/certbot
    apt update -y
    apt install -y certbot

    echo "--> GENERATING LETSENCRYPT CERTIFICATES"

    sudo service openvpnas stop
    sudo certbot certonly --standalone --non-interactive --agree-tos --email ${lets_encrypt_email} --domains ${lets_encrypt_domain} --pre-hook 'service openvpnas stop' --post-hook 'service openvpnas start' ${lets_encrypt_environment}
    sudo ln -s -f /etc/letsencrypt/live/${lets_encrypt_domain}/cert.pem /usr/local/openvpn_as/etc/web-ssl/server.crt
    sudo ln -s -f /etc/letsencrypt/live/${lets_encrypt_domain}/privkey.pem /usr/local/openvpn_as/etc/web-ssl/server.key
fi
# RESTART OPENVPN ACCESS SERVER TO SAVE AND APPLY CONFIGURATION CHANGES
sudo service openvpnas restart


--===============BOUNDARY==
