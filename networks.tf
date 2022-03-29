## Networks are sorted by Lexical order, and the FIRST 
## network is always the docker gateway.. important 
## to remember if you are going to attach more than one 
## network to a container with terraform!!

resource "docker_network" "bind_network" {
  name            = "01_bind_ingress"
  check_duplicate = true
  ipam_config {
    subnet   = "192.168.186.0/24"
    ip_range = "192.168.186.128/25"
    gateway  = "192.168.186.2"
  }
}