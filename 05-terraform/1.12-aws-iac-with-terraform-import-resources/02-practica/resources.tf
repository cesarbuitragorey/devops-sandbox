resource "aws_iam_policy" "custom_policy" {
  name        = "cmtr-iacp1ebx-iam-policy"
  description = "Custom role with limited permissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ec2:*", "s3:*"],
        Resource = "*"
      }
    ]
  })
}
