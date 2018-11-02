# tf-aws-openvpn
Terraform AWS OpenVPN Module

## Summary
This terraform module provisions OpenVPN Access Server in AWS
- Using the Official [OpenVPN](https://aws.amazon.com/marketplace/seller-profile?id=aac3a8a3-2823-483c-b5aa-60022894b89d&ref=dtl_B00MI40CAE) AMI via [AWS Marketplace](https://aws.amazon.com/marketplace)
- Configures OpenVPN via User Data
    - BYOL License  [openvpn.net](https://openvpn.net/)
    - Default Setup (Admin Credentials)
    - LDAP (e.g. JumpCloud, Active Directory)
- Configures AWS Security Group
- Configures AWS Route53 Records for Public and Private DNS
- Note: The Openvpn Admin Credential is randomly generated and stored in Terraform Remote State.
- Note: The LDAP Bind User Credential is Encrypted and stored in AWS SSM Parameter Store.

## SECURITY
The OpenVPN Access Server needs the following ports to be open for inbound traffic
which is provided by a custom security group.
* UDP 1194 (OPENVPN)
* TCP 943 (OPENVPN)
* TCP 443 (HTTPS)
* TCP 22 (SSH)

### LDAP CONFIGURATION
The LDAP Configuration is passed in via User Data and implemented via the OpenVPN
Access Server script ./sacli

## Example Implementation

    /project                        # Terraform Project
        /workspaces                 # Workspaces
            /ops                    # Operations Environment
                openvpn             # OpenVPN Stack using Module
                    backend.tf
                    data.tf
                    main.tf
                    providers.tf
            /dev                    # Development Environment
            /tst                    # Testing Environment
            /stg                    # Staging Environment
            /prd                    # Production Environment


### backend.tf

    terraform {
        backend "s3" {
            bucket               = "<bucket_name>"
            key                  = "openvpn"
            workspace_key_prefix = "terraform"
            region               = "us-east-1"
            profile              = "<profile_name>"
            role_arn             = "arn:aws:iam::<account_id>:role/<role_name>"
        }
    }

### data.tf

    data "terraform_remote_state" "network" {
        backend   = "s3"
        workspace = "${terraform.workspace}"

        config {
            bucket               = "<bucket_name>"
            key                  = "network"
            workspace_key_prefix = "terraform"
            region               = "us-east-1"
            profile              = "<profile_name>"
            role_arn             = "arn:aws:iam::<account_id>:role/<role_name>"
        }
    }

    data "aws_ssm_parameter" "openvpn_ldap_bind_pswd" {
        name  = "/<workspace>/openvpn/ldap_bind_pswd"
        with_decryption = true
    }


### main.tf

    resource "random_string" "password" {
        length  = 16
        upper   = true
        lower   = true
        number  = true
        special = true

        keepers = {
            env = "${terraform.workspace}"
        }
    }

    module "openvpn" {
        source                          = "git::ssh://git@github.com/gadgetry-io/tf-aws-openvpn.git?ref=master"
        network_vpc_id                  = "<vpc_id>"
        openvpn_ami                     = "<openvpn_ami>"
        openvpn_key_name                = "<provision_key>"
        openvpn_subnet_id               = "<subnet_id>"
        openvpn_route53_public_zone_id  = "<route53_public_zone_id>"
        openvpn_public_dns              = "openvpn.<public_domain_name>"
        openvpn_route53_private_zone_id = "<route53_private_zone_id>"
        openvpn_private_dns             = "openvpn.<private_domain_name>"
        openvpn_public_hostname         = "openvpn.<public_domain_name>"
        openvpn_admin_pswd              = "${random_string.password.result}"
        openvpn_license                 = "<openvpn_license>"
        openvpn_reroute_dns             = 1
        openvpn_all_access              = ["<cidr_block>","<cidr_block>]
        openvpn_ssh_access              = ["<cidr_block>","<cidr_block>]
        openvpn_ldap_server_1           = "<ldap_server>"  # e.g. ldap.jumpcloud.com
        openvpn_ldap_server_2           = "<ldap_server>"  # e.g. ldap.jumpcloud.com
        openvpn_ldap_bind_dn            = "uid=ldapuser,ou=Users,o=<account_id>,dc=jumpcloud,dc=com"
        openvpn_ldap_bind_pswd          = "${data.aws_ssm_parameter.openvpn_ldap_bind_pswd.value}"
        openvpn_ldap_base_dn            = "ou=Users,o=<account_id>,dc=jumpcloud,dc=com"
        openvpn_ldap_uname_attr         = "uid"
        openvpn_ldap_add_req            = "memberOf=cn=openvpn,ou=Users,o=<account_id>,dc=jumpcloud,dc=com"
        openvpn_ldap_use_ssl            = "always"
        custom_security_groups          = ["<security group ID", "security group ID"]
        public_ip                       = "<ip_address>" or ""
    }

### providers.tf

    provider aws {
        region  = "us-east-1"
        profile = "<profile_name>"
    }
