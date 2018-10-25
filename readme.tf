data "template_file" "readme" {
  template = <<EOF

# OPENVPN
This stack provisions an OpenVPN Access Server in the ${upper(terraform.workspace)} environment.

## LINKS
[OpenVPN Website](https://openvpn.net/)
[OpenVPN Documentation](https://docs.openvpn.net/)
[OpenVPN AMI on AWS Marketplace](https://aws.amazon.com/marketplace/pp/B00MI40CAE/ref=mkt_wir_openvpn_byol)
[OpenVPN Command Line Configuration](https://docs.openvpn.net/command-line/authentication-options-and-command-line-configuration/)

## CONFIGURATION

|ATTRIBUTE|VALUE|
|Instance ID|${aws_instance.openvpn.id}|
|Instance Size|${var.openvpn_instance_size}|
|Availability Zone|${aws_instance.openvpn.availability_zone}|
|Subnet ID|${aws_instance.openvpn.subnet_id}|
|Private DNS|${aws_instance.openvpn.private_dns}|
|Private IP|${aws_instance.openvpn.private_ip}|
|Public DNS|${var.openvpn_public_dns}|
|Public IP|${local.public_ip}|


### USER DATA
The following user data is used to configure the OpenVPN Access Server when
it is provisioned via Terraform.

#### public_hostname
${var.openvpn_public_hostname} is the hostname that clients should use to contact the server.

#### admin_user (default=openvpn)
${var.openvpn_admin_user} is the Access Server administrative account name.

#### admin_pw
The administrative account's initial password is set via a Random String Generator
and is stored in Terraform's Remote State.

#### license
OpenVPN Access Server is BYOL (Bring Your Own License).  During the initial provisioning
without specifying a license key, the Access Server will support up to 2 concurrent
connections.  The License Key, once purchased, can be configured via the Admin Web UI.

#### reroute_gw (boolean, default=0)
If 1, the reroute gateway setting will route client internet traffic through the VPN.
Generally you will want this to be the default set to 0. Note: This can be updated
manually via the Admin Web UI.

#### reroute_dns (boolean, default=0)
If 1, the reroute dns setting will route client DNS queries through the VPN. Generally
you will want this to be set to 1. Note: This can be updated manually via the Admin Web UI.

### LDAP CONFIGURATION
The LDAP Configuration is passed in via User Data and implemented via the OpenVPN
Access Server script ./sacli

|ATTRIBUTE|VALUE|
|LDAP Primary Server|${var.openvpn_ldap_server_1}|
|LDAP Secondary Server|${var.openvpn_ldap_server_2}|
|LDAP Bind DN|${var.openvpn_ldap_bind_dn}|
|LDAP Base DN|${var.openvpn_ldap_base_dn}|
|LDAP Username Attribute|${var.openvpn_ldap_uname_attr}|
|LDAP MemberOf Requirement|${var.openvpn_ldap_add_req}|
|LDAP Use SSL|${var.openvpn_ldap_use_ssl}|

#### EXAMPLE CONFIGURATION COMMANDS (./sacli)

    # To set authentication mode to LDAP:
    ./sacli --key "auth.module.type" --value "ldap" ConfigPut
    ./sacli start

    # To set primary LDAP server address:
    ./sacli --key "auth.ldap.0.server.0.host" --value "${var.openvpn_ldap_server_1}" ConfigPut
    ./sacli start

    # To set backup LDAP server address:
    ./sacli --key "auth.ldap.0.server.1.host" --value "${var.openvpn_ldap_server_2}" ConfigPut
    ./sacli start

    # To set bind credentials
    ./sacli --key "auth.ldap.0.bind_dn" --value "${var.openvpn_ldap_bind_dn}" ConfigPut
    ./sacli --key "auth.ldap.0.bind_pw" --value <PASSWORD> ConfigPut
    ./sacli start

    # To set Base DN to search for user entries:
    ./sacli --key "auth.ldap.0.users_base_dn" --value "${var.openvpn_ldap_base_dn}" ConfigPut
    ./sacli start

    # To set the LDAP Attribute that contains the user name:
    ./sacli --key "auth.ldap.0.uname_attr" --value "${var.openvpn_ldap_uname_attr}" ConfigPut
    ./sacli start

    # To set an additional LDAP MemberOf requirement:
    ./sacli --key "auth.ldap.0.add_req" --value "${var.openvpn_ldap_add_req}" ConfigPut
    ./sacli start

    # To configure using SSL over the connection to the LDAP server or not.
    # There are three possible choices:
    #    - never: do not use SSL (the default setting)
    #    - adaptive: try using SSL, if that fails, use plain-text
    #    - always: always use SSL
    ./sacli --key "auth.ldap.0.use_ssl" --value "${var.openvpn_ldap_use_ssl}" ConfigPut
    ./sacli start


## SECURITY
The OpenVPN Access Server needs the following ports to be open for inbound traffic
which is provided by a custom security group.
* UDP 1194 (OPENVPN)
* TCP 943 (OPENVPN)
* TCP 443 (HTTPS)
* TCP 22 (SSH)

### Inbound Rules
|ACTION|PORT|PROTOCOL|CIDR|NOTES|
|ALLOW|ALL|ALL|${join("\n", var.openvpn_all_access)}|Allow ALL (tcp/udp) access from these networks.|
|ALLOW|22|TCP|${join("\n", var.openvpn_ssh_access)} |Allow SSH(tcp 22) access from these networks.|
|ALLOW|443|TCP|${join("\n", var.openvpn_https_access)} |Allow HTTPS(tcp 443) access from these networks.|
|ALLOW|943|TCP|${join("\n", var.openvpn_admin_access)} |Allow Web/Admin UI Access (tcp 943) access from these networks.|
|ALLOW|22|TCP|${join("\n", var.openvpn_udp_access)} |Allow VPN (udp 1194) access from these networks.|


### Outbound Rules
|ACTION|PORT|PROTOCOL|CIDR|NOTES|
|ALLOW|ALL|ALL|0.0.0.0/0|Allow ALL (tcp/udp) access to these networks.|

EOF
}

resource "local_file" "readme" {
  content  = "${data.template_file.readme.rendered}"
  filename = "${path.root}/README.${upper(terraform.workspace)}.md"
}
