## Networks are sorted by Lexical order, and the FIRST 
## network is always the docker gateway.. important 
## to remember if you are going to attach more than one 
## network to a container with terraform!!

resource "docker_network" "zabbix_frontend" {
  name            = "01_zabbix_frontend"
  check_duplicate = true
  ipam_config {
    subnet   = "192.168.183.0/24"
    ip_range = "192.168.183.128/25"
    gateway  = "192.168.183.2"
  }
}

resource "docker_network" "zabbix_apps" {
  name            = "02_zabbix_apps"
  check_duplicate = true
  internal = false
  ipam_config {
    subnet   = "192.168.184.0/24"
    ip_range = "192.168.184.128/25"
    gateway  = "192.168.184.2"
  }
}

resource "docker_network" "zabbix_db" {
  name            = "03_zabbix_db"
  check_duplicate = true
  internal = true
  ipam_config {
    subnet   = "192.168.185.0/24"
    ip_range = "192.168.185.128/25"
    gateway  = "192.168.185.2"
  }
}
