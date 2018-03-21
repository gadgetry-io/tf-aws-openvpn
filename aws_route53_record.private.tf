# ROUTE53 PRIVATE DNS
resource "aws_route53_record" "private" {
  zone_id = "${var.openvpn_route53_private_zone_id}"
  name    = "${var.openvpn_private_dns}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.openvpn.private_ip}"]
}
