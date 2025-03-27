resource "google_compute_address" "egress-static-ip" {
  provider = google-beta
  for_each = var.connectors

  name = "${var.project_prefix}-${var.network}-${each.key}"
  labels = {
    managed-by = "terraform"
  }
}

# TODO: Create firewall rule as well (Better to be in vpc)
# LOL, openvpn does some magic, no firewall required

resource "google_compute_instance" "vpn-instance" {
  for_each = var.connectors

  name                      = "${var.project_prefix}-${var.network}-${each.key}"
  machine_type              = var.instance_size
  zone                      = var.zone
  allow_stopping_for_update = true

  tags = ["ovpn"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  can_ip_forward = true

  network_interface {
    network = var.vpc_name

    access_config {
      nat_ip = google_compute_address.egress-static-ip[each.key].address
    }
  }

  # The source of truth for this script should be https://gitlab.com/beecash/infra/scripts/-/blob/master/openvpn/setup.sh
  metadata_startup_script = <<-EOT
#!/bin/bash

# Install dependencies
sudo apt -y update
sudo apt -y install gpg curl

# Install the OpenVPN repository key used by the OpenVPN packages
curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg > /dev/null

# Add the OpenVPN repository
DISTRO=$(lsb_release -c | awk '{print $2}')
sudo curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$DISTRO.list -o /etc/apt/sources.list.d/openvpn3.list
sudo apt -y update

# Install OpenVPN Connector setup tool
sudo apt -y install python3-openvpn-connector-setup

# Enable IP forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sudo sysctl -p

# Configure NAT
IF=$(ip route | grep default | awk '{print $5}')
sudo iptables -t nat -A POSTROUTING -o $IF -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -o $IF -j MASQUERADE
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
sudo openvpn-connector-setup --token ${each.value}
EOT

  labels = {
    managed-by = "terraform"
  }
  lifecycle {
    ignore_changes = [
      metadata,
      metadata_startup_script
    ]
  }
}

locals {
  vpn_static_ips = {
    for connector in keys(var.connectors) : "OpenVPN ${var.network} ${connector}" => "${google_compute_address.egress-static-ip[connector].address}/32"
  }
}

output "vpn-egress-static-ips" {
  value = local.vpn_static_ips
}
