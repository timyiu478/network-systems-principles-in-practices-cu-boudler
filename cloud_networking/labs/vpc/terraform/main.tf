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

resource "google_compute_network" "tf-mode-lab1-vpc1" {
  name = "tf-mode-lab1-vpc1"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "tf-mode-lab1-vpc2" {
  name = "tf-mode-lab1-vpc2"
  auto_create_subnetworks = "false"
}


// Create the subnets
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "tf-mode-lab1-sub1" {
  name          = "tf-mode-lab1-sub1"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.tf-mode-lab1-vpc1.id
}

resource "google_compute_subnetwork" "tf-mode-lab1-sub2" {
  name          = "tf-mode-lab1-sub2"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.tf-mode-lab1-vpc2.id
}

resource "google_compute_subnetwork" "tf-mode-lab1-sub3" {
  name          = "tf-mode-lab1-sub3"
  ip_cidr_range = "10.0.3.0/24"
  region        = "us-central1"
  network       = google_compute_network.tf-mode-lab1-vpc2.id
}


// Create Firewall rules
//https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "tf-mode-lab1-fwrule1" {
  project = "DETACHED"
  name        = "tf-mode-lab1-fwrule1"
  network     = "tf-mode-lab1-vpc1"
  // need the network created before the firewall rule
  // I noticed sometimes terraform didn't detect the dependency, so making explicit.
  depends_on = [google_compute_network.tf-mode-lab1-vpc1]

  allow {
    protocol  = "tcp"
    ports     = ["22", "1234"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tf-mode-lab1-fwrule2" {
  project = "DETACHED"
  name        = "tf-mode-lab1-fwrule2"
  network     = "tf-mode-lab1-vpc2"
  // need the network created before the firewall rule
  // I noticed sometimes terraform didn't detect the dependency, so making explicit.
  depends_on = [google_compute_network.tf-mode-lab1-vpc2]

  allow {
    protocol  = "tcp"
    ports     = ["22", "1234"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

// Create a VMs
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
resource "google_compute_instance" "tf-mode-lab1-vm1" {
  name = "tf-mode-lab1-vm1"
  machine_type = "e2-micro"
  zone = "us-central1-a"  
  depends_on = [google_compute_network.tf-mode-lab1-vpc1, google_compute_subnetwork.tf-mode-lab1-sub1]
  network_interface {
    // This indicates to give a public IP address
    access_config {
      network_tier = "STANDARD"
    }
    network = "tf-mode-lab1-vpc1"
    subnetwork = "tf-mode-lab1-sub1"
  }

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240312"
    }
  } 
  metadata = {
    startup-script = "sudo apt update; sudo apt install netcat-traditional ncat;"
  }

}

resource "google_compute_instance" "tf-mode-lab1-vm2" {
  name = "tf-mode-lab1-vm2"
  machine_type = "e2-micro"
  zone = "us-central1-a"  
  depends_on = [google_compute_network.tf-mode-lab1-vpc2, google_compute_subnetwork.tf-mode-lab1-sub2]
  network_interface {
    // This indicates to give a public IP address
    access_config {
      network_tier = "STANDARD"
    }
    network = "tf-mode-lab1-vpc2"
    subnetwork = "tf-mode-lab1-sub2"
  }

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240312"
    }
  } 
  metadata = {
    startup-script = "sudo apt update; sudo apt install netcat-traditional ncat;"
  }

}

resource "google_compute_instance" "tf-mode-lab1-vm3" {
  name = "tf-mode-lab1-vm3"
  machine_type = "e2-micro"
  zone = "us-central1-a"  
  depends_on = [google_compute_network.tf-mode-lab1-vpc2, google_compute_subnetwork.tf-mode-lab1-sub2]
  network_interface {
    // This indicates to give a public IP address
    access_config {
      network_tier = "STANDARD"
    }
    network = "tf-mode-lab1-vpc2"
    subnetwork = "tf-mode-lab1-sub2"
  }

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240312"
    }
  } 
  metadata = {
    startup-script = "sudo apt update; sudo apt install netcat-traditional ncat;"
  }

}

resource "google_compute_instance" "tf-mode-lab1-vm4" {
  name = "tf-mode-lab1-vm4"
  machine_type = "e2-micro"
  zone = "us-central1-a"  
  depends_on = [google_compute_network.tf-mode-lab1-vpc2, google_compute_subnetwork.tf-mode-lab1-sub3]
  network_interface {
    // This indicates to give a public IP address
    access_config {
      network_tier = "STANDARD"
    }
    network = "tf-mode-lab1-vpc2"
    subnetwork = "tf-mode-lab1-sub3"
  }

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240312"
    }
  } 
  metadata = {
    startup-script = "sudo apt update; sudo apt install netcat-traditional ncat;"
  }

}
