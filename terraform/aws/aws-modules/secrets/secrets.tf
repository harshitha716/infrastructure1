resource "aws_secretsmanager_secret" "secrets" {
  for_each = { for idx, secret in var.secrets : secret.name => secret }

  name        = each.value.name
  description = each.value.description
  kms_key_id  = aws_kms_key.secrets_kms_key.arn

  tags = merge(each.value.tags, {
    Name = each.value.name
  }) 
}

