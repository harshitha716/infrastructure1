resource "aws_iam_role" "snowflake_role" {
  name        = "snowflake-role"
  description = "Snowflake role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::650251688455:user/9d0s0000-s"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "LDB28940_SFCRole=3_2l9nzeOjCruFAMGC01LhHq452ZQ="
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "snowflake_policy" {
  name        = "snowflake-s3-policy"
  description = "Policy for Snowflake S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
        Condition = {
          StringLike = {
            "s3:prefix": [
              "*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.snowflake_policy.arn
}

output "snowflake_role_arn" {
  value = aws_iam_role.snowflake_role.arn
}
