resource "google_compute_resource_policy" "daily_snapshot_policy" {
  name   = "${var.project_prefix}-daily"

  snapshot_schedule_policy {
    schedule {
          daily_schedule{
              days_in_cycle = 1
              start_time = "01:00"
          }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = {
        schedule-type = "daily"
      }
      storage_locations = ["${var.region}"]
      guest_flush       = true
    }
}
}

resource "google_compute_resource_policy" "hourly_snapshot_policy" {
  name   = "${var.project_prefix}-hourly"
  snapshot_schedule_policy {
    schedule {
          hourly_schedule{
              hours_in_cycle = 6
              start_time = "00:00"
          }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = {
        schedule-type = "hourly"
      }
      storage_locations = ["${var.region}"]
      guest_flush       = true
    }
}
}

resource "google_compute_resource_policy" "weekly_snapshot_policy" {
  name   = "${var.project_prefix}-weekly"

  snapshot_schedule_policy {
    schedule {
          weekly_schedule{
            day_of_weeks{
                day = "SUNDAY"
                start_time = "00:00"
            }
          }
    }
    retention_policy {
      max_retention_days    = 30
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = {
        schedule-type = "daily"
      }
      storage_locations = ["${var.region}"]
      guest_flush       = true
    }
}
}

resource "google_compute_disk_resource_policy_attachment" "daily_snapshot_policy_attachment" {
  name  = google_compute_resource_policy.daily_snapshot_policy.name
  for_each  = {for i in var.boot_disks : i["name"] => i if i["policy"]=="daily"} 
  disk  = each.key
  zone  =  lookup(each.value, "zone", null)
}

resource "google_compute_disk_resource_policy_attachment" "hourly_snapshot_policy_attachment" {
  name  = google_compute_resource_policy.hourly_snapshot_policy.name
  for_each  = {for i in var.boot_disks : i["name"] => i if i["policy"]=="hourly"} 
  disk  = each.key  
  zone  =  lookup(each.value, "zone", null)
}

resource "google_compute_disk_resource_policy_attachment" "weekly_snapshot_policy_attachment" {
  name  = google_compute_resource_policy.weekly_snapshot_policy.name
  for_each  = {for i in var.boot_disks : i["name"] => i if i["policy"]=="weekly"} 
  disk  = each.key
  zone  =  lookup(each.value, "zone", null)
}


