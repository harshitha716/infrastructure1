resource "google_spanner_instance" "cloudspanner" {
  config       = "regional-${var.region}"
  display_name = "${var.proj_prefix}-cloudspanner"
  processing_units    = var.processing_units
  labels = {
    "env" = "${var.environment}"
  }
  name = "${var.proj_prefix}-cloudspanner"

  lifecycle {
    # create_before_destroy = true
    ignore_changes = [name, config , labels]
  }                                                           

}


