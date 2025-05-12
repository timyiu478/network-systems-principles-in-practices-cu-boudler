terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}


// Note: If you need to reference the outputs (assigned values)
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#id
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#id


// Create the VPCs

resource "google_compute_network" "tf-mod3-lab-vpc1" {
  name = "tf-mod3-lab-vpc1"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "tf-mod3-lab-vpc2" {
  name = "tf-mod3-lab-vpc2"
  auto_create_subnetworks = "false"
}


// Create the subnets
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "tf-mod3-lab-sub1" {
  name          = "tf-mod3-lab-sub1"
  ip_cidr_range = "172.16.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.tf-mod3-lab-vpc1.id
}

resource "google_compute_subnetwork" "tf-mod3-lab-sub2" {
  name          = "tf-mod3-lab-sub2"
  ip_cidr_range = "172.16.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.tf-mod3-lab-vpc2.id
}

// Create VPC peerings
resource "google_compute_network_peering" "tf-mod3-lab-peering1" {
  name         = "tf-mod3-lab-peering1"
  network      = google_compute_network.tf-mod3-lab-vpc1.self_link
  peer_network = google_compute_network.tf-mod3-lab-vpc2.self_link
}

resource "google_compute_network_peering" "tf-mod3-lab-peering2" {
  name         = "tf-mod3-lab-peering2"
  network      = google_compute_network.tf-mod3-lab-vpc2.self_link
  peer_network = google_compute_network.tf-mod3-lab-vpc1.self_link
}

// Create a Router in VPC 2
resource "google_compute_router" "tf-mod3-lab-router1" {
  name    = "tf-mod3-lab-router1"
  network = google_compute_network.tf-mod3-lab-vpc2.name
  region  = "us-east1"
}

// Create a Router NAT in VPC 2
resource "google_compute_router_nat" "tf-mod3-lab-nat1" {
  name                               = "tf-mod3-lab-nat1"
  router                             = google_compute_router.tf-mod3-lab-router1.name
  region                             = "us-east1"
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.tf-mod3-lab-sub2.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

// Create a VMs
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
resource "google_compute_instance" "tf-mod3-lab-vm1" {
  name = "tf-mod3-lab-vm1"
  machine_type = "e2-micro"
  zone = "us-central1-a"  
  depends_on = [google_compute_network.tf-mod3-lab-vpc1, google_compute_subnetwork.tf-mod3-lab-sub1]
  network_interface {
    network = "tf-mod3-lab-vpc1"
    subnetwork = "tf-mod3-lab-sub1"
  }

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240312"
    }
  } 
  metadata = {
    startup-script = "sudo apt update; sudo apt install netcat-traditional ncat;sudo ip link add vxlan0 type vxlan id 5001 local 172.16.0.2 remote 172.16.1.2 dev ens4 dstport 50000; sudo ip addr add 192.168.100.2/24 dev vxlan0; sudo ip link set up dev vxlan0; sudo ip route add 34.223.124.45/32 via 192.168.100.3;"
  }

}

resource "google_compute_instance" "tf-mod3-lab-vm2" {
  name = "tf-mod3-lab-vm2"
  machine_type = "e2-micro"
  zone = "us-east1-b"  
  depends_on = [google_compute_network.tf-mod3-lab-vpc2, google_compute_subnetwork.tf-mod3-lab-sub2]
  network_interface {
    network = "tf-mod3-lab-vpc2"
    subnetwork = "tf-mod3-lab-sub2"
  }

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240312"
    }
  } 
  metadata = {
    startup-script = "sudo apt update; sudo apt install netcat-traditional ncat; sudo ip link add vxlan0 type vxlan id 5001 remote 172.16.0.2 local 172.16.1.2 dev ens4 dstport 50000; sudo ip addr add 192.168.100.3/24 dev vxlan0; sudo ip link set up dev vxlan0; sudo /sbin/sysctl -w net.ipv4.ip_forward=1; sudo /sbin/iptables -t nat -A POSTROUTING -s 192.168.0.0/16 -o ens4 -j MASQUERADE;"
  }

}

# Create Firewall rules
resource "google_compute_firewall" "tf-mod3-lab-fwrule1" {
  project = local.project
  name        = "tf-mod3-lab-fwrule1"
  network     = "tf-mod3-lab-vpc1"
  depends_on = [google_compute_network.tf-mod3-lab-vpc1]

  allow {
    protocol  = "udp"
    ports     = ["50000"]
  }

  allow {
    protocol  = "tcp"
    ports     = ["22", "1234"]
  }
  
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tf-mod3-lab-fwrule2" {
  project = local.project
  name        = "tf-mod3-lab-fwrule2"
  network     = "tf-mod3-lab-vpc2"
  depends_on = [google_compute_network.tf-mod3-lab-vpc2]

  allow {
    protocol  = "udp"
    ports     = ["50000"]
  }

  allow {
    protocol  = "tcp"
    ports     = ["22", "1234", "50000"]
  }
  
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
