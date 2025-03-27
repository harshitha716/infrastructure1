variable project_id {
  description = "project_id"
}
variable project_prefix {
  description = "project_prefix"
}
variable region {
  description = "region"
}
# variable zone {
#   description = "zone"
# }
variable "boot_disks" {
}
variable enable_hourly_snapshot{
  default = false
}
variable enable_daily_snapshot{
  default = false
}