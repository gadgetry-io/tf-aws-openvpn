provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.acme_registration_email}"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = "${acme_registration.reg.account_key_pem}"
  common_name               = "${var.openvpn_public_hostname}"

  dns_challenge {
    provider = "route53"

    config {
      AWS_PROFILE        = "${var.aws_profile}"
      AWS_DEFAULT_REGION = "${var.aws_region}"

    }
  }
}

# Attributes:
# -----------
# acme_certificate.certificate.private_key_pem
# acme_certificate.certificate.certificate_pem
# acme_certificate.certificate.issuer_pem
#
