resource "aws_db_subnet_group" "rds-sg" {
    description = "RDS Subnet Group"
    name = var.subnet_group_name
    subnet_ids = var.private_subnet_ids
}


### RDS Parameter Group ###

resource "aws_db_parameter_group" "rds-pg" {
    description = "Parameter group for the db "
    family = var.rds["zamp-prd-uae-db-instance"].parameter_group_family
    name   = var.rds["zamp-prd-uae-db-instance"].parameter_group_name

}
  
### RDS ###
resource "aws_db_instance" "rds" {
  for_each = var.rds

  identifier           = each.value.db_identifier
  instance_class       = each.value.instance_class
  allocated_storage    = each.value.allocated_storage
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  db_name              = each.value.db_name
  username             = each.value.db_username
  password             = each.value.db_password

  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  backup_retention_period    = each.value.backup_retention_period
  copy_tags_to_snapshot      = each.value.copy_tags_to_snapshot
  db_subnet_group_name       = aws_db_subnet_group.rds-sg.name
  parameter_group_name       = aws_db_parameter_group.rds-pg.name
  monitoring_interval        = 0  # Disable Enhanced Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled = each.value.performance_insights_enabled
  performance_insights_retention_period = each.value.performance_insights_retention_period
  multi_az                   = each.value.multi_az
  publicly_accessible        = each.value.publicly_accessible
  skip_final_snapshot        = each.value.skip_final_snapshot
  storage_encrypted          = each.value.storage_encrypted
  storage_type               = each.value.storage_type
  vpc_security_group_ids     = [aws_security_group.db_sg.id]
  deletion_protection        = each.value.deletion_protection
  kms_key_id                 = aws_kms_key.kms.arn

  tags = merge(var.tags, {
    Name = each.value.db_identifier
  })
}
 



