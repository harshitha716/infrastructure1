resource "aws_kms_key" "kms" {
  description = "KMS key for RDS created by rapyder"
  enable_key_rotation     = true
  multi_region            = true
  deletion_window_in_days = 7
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "key-default-1",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "*"
            ]
          },
          "Action" : "kms:*",
          "Resource" : "*"
        }
      ]
    }
  )
  tags = {
    Name = var.kms_key_name
  }
}


resource "aws_kms_alias" "kms" {
  name = "alias/${var.kms_key_name}"
  target_key_id = aws_kms_key.kms.key_id
}
