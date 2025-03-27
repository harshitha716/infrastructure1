resource "google_spanner_database" "database" {
  instance            = var.spanner_instance_name
  name                = var.spanner_db_name
  deletion_protection = true
}