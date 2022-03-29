terraform {
  backend "etcdv3" {
    endpoints = ["192.168.178.88:2379"]
    lock      = true
    prefix    = "terraform-state/home_bind9"
  }
}

# Configure the Docker provider
provider "docker" {
  #host =  "unix:///var/run/docker.sock"
  host = "ssh://${var.docker_host}"
}
