data "google_project" "project" {
}


locals {
  pubsub_topics = { for x in var.pubsub_topics : x.name => x }
  pubsub_subs_map = flatten([ for x in var.pubsub_topics : [for y in x.subscriptions : {        
        name                    = x.name
        dlq_enabled             = x.dlq_enabled
        ack_deadline_seconds    = x.ack_deadline_seconds
        enable_message_ordering = x.enable_message_ordering
        enable_exactly_once_delivery = x.enable_exactly_once_delivery
        subscriptions           = y }]])
  pubsub_subs = { for x in local.pubsub_subs_map : x.subscriptions => x }
  dlq_topics    = [for x in var.pubsub_topics : "${x.name}-dlq" if x.dlq_enabled]
}

resource "google_pubsub_topic" "topic" {
  depends_on = [google_kms_crypto_key.pubsub]
  for_each = tomap(local.pubsub_topics)
  name     = each.value.name
  kms_key_name = var.kms_key_name == "" ? google_kms_crypto_key.pubsub[0].id : "projects/${var.project_id}/locations/${var.region}/keyRings/${var.kms_key_name}/cryptoKeys/${var.kms_key_name}"
}

resource "google_pubsub_topic" "dlq" {
  depends_on = [google_kms_crypto_key.pubsub]
  for_each = toset(local.dlq_topics)
  name     = each.value
  kms_key_name = var.kms_key_name == "" ? google_kms_crypto_key.pubsub[0].id : "projects/${var.project_id}/locations/${var.region}/keyRings/${var.kms_key_name}/cryptoKeys/${var.kms_key_name}"
}

resource "google_pubsub_subscription" "subscription" {
  for_each = tomap(local.pubsub_subs)
  name     = "${each.key}-subscription"
  topic    = each.value.name

  dynamic "dead_letter_policy" {
    for_each = each.value.dlq_enabled ? [each.value.name] : []
    content {
      dead_letter_topic     = "projects/${data.google_project.project.project_id}/topics/${dead_letter_policy.value}-dlq"
      max_delivery_attempts = 5
    }
  }

  #   retry_policy {
  #     minimum_backoff = "10s"
  #     maximum_backoff = "600s"
  #   }

  expiration_policy {
    ttl = ""
  }

  enable_message_ordering =  each.value.enable_message_ordering
  enable_exactly_once_delivery = each.value.enable_exactly_once_delivery
  ack_deadline_seconds = each.value.ack_deadline_seconds
  labels = {
    managed-by = "terraform"
  }
  depends_on = [
    google_pubsub_topic.topic,
    google_pubsub_topic.dlq
  ]
}

###############
#deadletter 

resource "google_pubsub_subscription" "subscription-dlq" {
  for_each = tomap(local.pubsub_topics)
  name     = "${each.value.name}-subscription-dlq"
  topic    = "${each.value.name}-dlq"
  enable_message_ordering = each.value.enable_message_ordering
  enable_exactly_once_delivery = each.value.enable_exactly_once_delivery
  ack_deadline_seconds = each.value.ack_deadline_seconds
  labels = {
    managed-by = "terraform"
  }
  expiration_policy {
    ttl = ""
  }
  
  depends_on = [
    google_pubsub_topic.topic,
    google_pubsub_topic.dlq
  ]
}

################



resource "google_pubsub_topic_iam_binding" "publish" {
  for_each = tomap(local.pubsub_topics)
  topic    = "projects/${data.google_project.project.project_id}/topics/${each.key}"
  role     = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${var.service_account}"
  ]
  depends_on = [
    google_pubsub_topic.topic
  ]
}

resource "google_pubsub_topic_iam_binding" "topic_view" {
  for_each = tomap(local.pubsub_topics)
  topic    = "projects/${data.google_project.project.project_id}/topics/${each.key}"
  role     = "roles/pubsub.viewer"
  members = [
    "serviceAccount:${var.service_account}"
  ]
  depends_on = [
    google_pubsub_topic.topic
  ]
}

resource "google_pubsub_subscription_iam_binding" "subscribe" {
  for_each     = tomap(local.pubsub_subs)
  subscription = "projects/${data.google_project.project.project_id}/subscriptions/${each.key}-subscription"
  role         = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:${var.service_account}"
  ]
  depends_on = [
    google_pubsub_subscription.subscription
  ]
}

resource "google_pubsub_subscription_iam_binding" "subscription_view" {
  for_each     = tomap(local.pubsub_subs)
  subscription = "projects/${data.google_project.project.project_id}/subscriptions/${each.key}-subscription"
  role         = "roles/pubsub.viewer"
  members = [
    "serviceAccount:${var.service_account}"
  ]
  depends_on = [
    google_pubsub_subscription.subscription
  ]
}


###############

resource "google_pubsub_subscription_iam_binding" "subscribe-dlq" {
  for_each     = tomap(local.pubsub_topics)
  subscription = "projects/${data.google_project.project.project_id}/subscriptions/${each.key}-subscription-dlq"
  role         = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:${var.service_account}"
  ]
  depends_on = [
    google_pubsub_subscription.subscription
  ]
}

resource "google_pubsub_subscription_iam_binding" "subscription_view-dlq" {
  for_each     = tomap(local.pubsub_topics)
  subscription = "projects/${data.google_project.project.project_id}/subscriptions/${each.key}-subscription-dlq"
  role         = "roles/pubsub.viewer"
  members = [
    "serviceAccount:${var.service_account}"
  ]
  depends_on = [
    google_pubsub_subscription.subscription
  ]
}

resource "google_kms_key_ring" "pubsub" {
  count = var.kms_key_name == "" ? 1 : 0
  name     = "${var.project_prefix}-pubsub"
  location = var.region
}

resource "google_kms_crypto_key" "pubsub" {
  count = var.kms_key_name == "" ? 1 : 0
  name            = "${var.project_prefix}-pubsub"
  key_ring        = google_kms_key_ring.pubsub[0].id
  rotation_period = var.kms_rotation_duration

  # lifecycle {
  #   prevent_destroy = true
  # }
}