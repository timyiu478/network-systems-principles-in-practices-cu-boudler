provider "google" {
  credentials = file("privateKey.json")

  project = local.project
  region  = "us-central1"  // default
  zone    = "us-central1-c"  // default
}
