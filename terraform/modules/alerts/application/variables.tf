
variable "project_id" {
  description = "Project Id"
}

variable "user_labels" {
  description = "User Labels"
}

variable "notification_channels" {
  description = "Notification Channel IDs"
}

locals {
  notification_channels = [for channel in var.notification_channels : "projects/${var.project_id}/notificationChannels/${channel}"]
}