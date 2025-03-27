data "google_project" "project" {
}

resource "google_kms_key_ring" "key_ring" {
  name     = var.key_ring_name
  location = var.location
}

resource "google_kms_crypto_key" "crypto_key" {
  name            = var.crypto_key_name
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.kms_rotation_duration

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "google_kms_crypto_key_iam_member" "crypto_key_encrypter_decrypter" {
  crypto_key_id = google_kms_crypto_key.crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = var.iam_member
}

resource "google_kms_crypto_key_iam_member" "crypto_key_decrypter" {
  crypto_key_id = google_kms_crypto_key.crypto_key.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = var.iam_member
}

resource "google_kms_key_ring_iam_member" "key_ring_encrypter_decrypter" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = var.iam_member
}

resource "google_kms_key_ring_iam_member" "key_ring_decrypter" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role        = "roles/cloudkms.cryptoKeyDecrypter"
  member      = var.iam_member
}