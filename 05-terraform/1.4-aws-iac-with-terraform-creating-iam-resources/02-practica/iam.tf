data "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}

resource "aws_iam_group" "this" {
  name = var.iam_group_name
}

resource "aws_iam_policy" "this" {
  name = var.iam_policy_name
  policy = templatefile("${path.module}/policy.json", {
    bucket_arn = data.aws_s3_bucket.existing.arn
  })

  tags = {
    Project = var.project_tag
  }
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.this.name

  tags = {
    Project = var.project_tag
  }
}
