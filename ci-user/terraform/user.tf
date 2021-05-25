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
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::tfstate-512334169695"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::tfstate-512334169695/*"
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
