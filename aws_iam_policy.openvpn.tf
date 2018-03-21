# WRITE IAM POLICY DOCUMENT
data "aws_iam_policy_document" "openvpn" {
  statement = [
    {
      effect = "Allow"

      actions = [
        "ec2:DescribeTags",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "cloudwatch:Get*",
        "cloudwatch:Describe*",
        "cloudwatch:List*",
        "cloudwatch:PutMetricData",
      ]

      resources = ["*"]
    }
  ]
}

# CREATE IAM POLICY
resource "aws_iam_policy" "openvpn" {
  name   = "${terraform.workspace}_openvpn"
  path   = "/"
  policy = "${data.aws_iam_policy_document.openvpn.json}"
}


# ATTACH IAM POLICY
resource "aws_iam_role_policy_attachment" "attach_openvpn_policy_to_openvpn_role" {
  role       = "${aws_iam_role.openvpn.name}"
  policy_arn = "${aws_iam_policy.openvpn.arn}"
}
