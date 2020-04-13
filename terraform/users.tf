resource "aws_iam_user" "pi" {
  name = "pi-user"
}

resource "aws_iam_user_policy_attachment" "pi" {
  user       = aws_iam_user.pi.name
  policy_arn = aws_iam_policy.authorize_ingress.arn
}

resource "aws_iam_access_key" "pi" {
  user = aws_iam_user.pi.name
}

data "aws_iam_policy_document" "authorize_ingress" {
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "authorize_ingress" {
  name   = "authorize-ingress-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.authorize_ingress.json
}

output "pi_access_key_id" {
  value = aws_iam_access_key.pi.id
}

output "pi_secret_access_key" {
  sensitive = true
  value = aws_iam_access_key.pi.secret
}