# NETWORK VARIABLES
variable network_vpc_id {
  type = "string"
}

# OPENVPN INSTANCE VARIABLES
variable stack_name {
  default = "openvpn"
}

variable openvpn_ami {
  type = "string"
}

variable openvpn_instance_size {
  default = "t2.medium"
  type = "string"
}

variable openvpn_key_name {
  type = "string"
}

variable openvpn_subnet_id {
  type = "string"
}

variable openvpn_route53_public_zone_id {
  type = "string"
}

variable openvpn_public_dns {
  type = "string"
}

variable openvpn_route53_private_zone_id {
  type = "string"
}

variable openvpn_private_dns {
  type = "string"
}

###############################################################################
### OPENVPN USER DATA
###############################################################################

# public_hostname
# -- hostname that clients should use to contact the server.
variable openvpn_public_hostname {
  type = "string"
}

# admin_user (default=openvpn)
# -- Access Server administrative account name.
variable openvpn_admin_user {
  type = "string"
  default = "openvpn"
}

# admin_pw
# -- administrative account initial password. Note that this parameter is
# communicated to the instance via a cleartext channel. A more secure method
# would be to ssh to the instance and use the passwd command to set the password.
variable openvpn_admin_pswd {
  type = "string"
}

# license
#-- Access Server license key (without a license key, the Access Server will
# support up to 2 concurrent connections).
variable openvpn_license {
  type = "string"
  default = ""
}

# reroute_gw (boolean, default=0)
# -- if 1, clients will route internet traffic through the VPN.
variable openvpn_reroute_gw {
  default = 0
}

# reroute_dns (boolean, default=0)
# -- if 1, clients will route DNS queries through the VPN.
variable openvpn_reroute_dns {
  default = 0
}

###############################################################################
### SECURITY GROUP CONFIGURATION
###############################################################################

# List of additional security group ID's to add to EC2 instance
variable custom_security_groups {
  type = "list"
  default = []
}

# WHITELIST CIDR_BLOCK(s) FOR ALL TRAFFIC (All TCP/UDP)
# (e.g. Private CIDR_BLOCK)
variable openvpn_all_access {
  type = "list"
}

# WHITELIST CIDR_BLOCK(s) FOR SSH TRAFFIC (TCP 22)
# (e.g. Office Network CIDR_BLOCK)
variable openvpn_ssh_access {
  type = "list"
}

# WHITELIST CIDR_BLOCK(s) FOR HTTPS TRAFFIC (TCP 443)
# (e.g. Public Network, Office Network CIDR_BLOCK)
variable openvpn_https_access {
  type = "list"
  default = [
    "0.0.0.0/0",
  ]
}

# WHITELIST CIDR_BLOCK(s) FOR ADMIN TRAFFIC (TCP 943)
# (e.g. Public Network CIDR_BLOCK)
variable openvpn_admin_access {
  type = "list"
  default = [
    "0.0.0.0/0",
  ]
}

# WHITELIST CIDR_BLOCK(s) FOR UDP TRAFFIC (UDP 1194)
# (e.g. Public Network)
variable openvpn_udp_access {
  type = "list"
  default = [
    "0.0.0.0/0",
  ]
}

###############################################################################
### LDAP CONFIGURATION
###############################################################################

variable openvpn_ldap_server_1 {
  type = "string"
}

variable openvpn_ldap_server_2 {
  type = "string"
}

variable openvpn_ldap_bind_dn {
  type = "string"
}

variable openvpn_ldap_bind_pswd {
  type = "string"
}

variable openvpn_ldap_base_dn {
  type = "string"
}

variable openvpn_ldap_uname_attr {
  type = "string"
  default = "uid"
  # sAMAccountName for Active Directory
  # uid for OpenLDAP
}

variable openvpn_ldap_add_req {
  type = "string"
}

variable openvpn_ldap_use_ssl {
  type = "string"
  default = "always"

}

###############################################################################
### USE PREALLOCATED FIXED ELASTIC IP
###############################################################################
variable public_ip {
  default = ""
  type = "string"
  description = "To use preallocated static IP address, please set variable to existing EIP. If it's empty, it will be created dynamically."
}
