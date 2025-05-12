provider "google" {
  credentials = file("privateKey.json")

  project = "DETEACHED"
  region  = "us-central1"  // default
  zone    = "us-central1-c"  // default
}
