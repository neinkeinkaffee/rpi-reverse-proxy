resource "aws_iam_user" "circleci_user" {
  name = "circleci"
}

resource "aws_iam_access_key" "circleci_access_key" {
  user = aws_iam_user.circleci_user.name
}

resource "aws_iam_user_policy" "lb_ro" {
  name = "circleci"
  user = aws_iam_user.circleci_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:AuthorizeSecurityGroupIngress",
              "ec2:RevokeSecurityGroupIngress"
          ],
          "Resource": "arn:aws:ec2:*:*:security-group/proxy_sg"
      },
      {
          "Action": [
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeSecurityGroupReferences",
              "ec2:DescribeVpcs"
          ],
          "Effect": "Allow",
          "Resource": "*"
      }
  ]
}
EOF
}

output "circleci_access_key_id" {
  value = aws_iam_access_key.circleci_access_key.id
}

output "circleci_access_key_secret" {
  value = aws_iam_access_key.circleci_access_key.secret
}
