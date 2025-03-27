locals {
  ssh_keys_list = [for username, publickey in var.ssk_keys : "${username}:${publickey} ${username}"]
}

resource "google_compute_project_metadata_item" "sshkeys" {
  key   = "ssh-keys"
  value = join("\n",local.ssh_keys_list)

#   lifecycle {
#       ignore_changes = all
#   }
}