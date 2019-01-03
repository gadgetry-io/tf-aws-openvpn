# SECURITY GROUP FOR OPENVPN ACCESS SERVER
resource "aws_security_group" "openvpn" {
  name        = "${terraform.workspace}_public_vpn"
  description = "${upper(terraform.workspace)} Public VPN Security Rules"
  vpc_id      = "${var.network_vpc_id}"

  tags {
    Name        = "${lower(terraform.workspace)}_${lower(var.stack_name)}"
    Environment = "${lower(terraform.workspace)}"
    Stack       = "${lower(var.stack_name)}"
  }
}

resource "aws_security_group_rule" "openvpn_all_access" {
  type              = "ingress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["${var.openvpn_all_access}"]
}

resource "aws_security_group_rule" "openvpn_ssh_access" {
  type              = "ingress"
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["${var.openvpn_ssh_access}"]
}

resource "aws_security_group_rule" "openvpn_https_access" {
  type              = "ingress"
  to_port           = 443
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["${var.openvpn_https_access}"]
}

# This rule is necessary if you plan to use LetsEncrypt certbot. It needs access to port 80 without IP restrictions to
# allow certbot to do it's automated verification
resource "aws_security_group_rule" "openvpn_http_access" {
  count             = "${var.use_lets_encrypt == "1" ? 1 : 0}"
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "openvpn_admin_access" {
  type              = "ingress"
  to_port           = 943
  from_port         = 943
  protocol          = "tcp"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["${var.openvpn_admin_access}"]
}

resource "aws_security_group_rule" "openvpn_udp_access" {
  type              = "ingress"
  to_port           = 1194
  from_port         = 1194
  protocol          = "udp"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["${var.openvpn_udp_access}"]
}

resource "aws_security_group_rule" "openvpn_egress" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.openvpn.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
