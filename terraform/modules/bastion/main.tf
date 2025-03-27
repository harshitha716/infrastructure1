# LOCALS

locals {
  ssh_keys_list = [for username, publickey in var.ssk_keys : "${username}:${publickey} ${username}"]
}


# ZONE
data "google_compute_zones" "available" {
}

# STATIC IP
resource "google_compute_address" "static" {
  name         = "${var.proj_prefix}-bastion"
  network_tier = "STANDARD"
}

# IMAGE (gcloud compute images list)
data "google_compute_image" "image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
} 

# BASTION SERVICE ACCOUNT
resource "google_service_account" "bastion" {
  account_id   = "${var.proj_prefix}-bastion"
  display_name = "${var.proj_prefix}-bastion"
}

resource "google_project_iam_member" "bastion_role" {
  for_each = toset(var.iam_roles)

  role    = each.key
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# STARTUP SCRIPT
data "template_file" "startup_script" {
  template = file("${path.module}/templates/startup_script.sh")
  vars = {
    ssh_port = var.ssh_port
  }
}

# BASTION
resource "google_compute_instance" "bastion" {

  name         = "${var.proj_prefix}-bastion"
  hostname     = "${var.proj_prefix}-bastion.local"

  #  If you want to update this value (resize the VM) after initial creation
  allow_stopping_for_update = true
  deletion_protection       = false

  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.name
      size  = var.root_disk_size
    }
  }

  tags         = var.networks_tags
  zone         = data.google_compute_zones.available.names[0]
  network_interface {
    subnetwork = var.subnet
    // If var.static_ip is set use that IP, otherwise this will generate an ephemeral IP
    access_config {
        nat_ip       = google_compute_address.static.address
        network_tier = "STANDARD"
    }
  }

  metadata_startup_script = data.template_file.startup_script.rendered

  metadata = {
    enable-oslogin         = var.enable_oslogin ? "TRUE" : "FALSE"
    ssh-keys               = length(local.ssh_keys_list) > 0 ? join("\n",local.ssh_keys_list) : null
    block-project-ssh-keys = var.block_project_ssh_keys

  }

  service_account {
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        email  = google_service_account.bastion.email
        scopes = ["cloud-platform"]
  }

  scheduling {
        preemptible = false
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
  }
  lifecycle {
    ignore_changes =  [boot_disk[0].initialize_params[0].image]
  }
}

