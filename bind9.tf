
data "docker_registry_image" "bind9" {
  name = "internetsystemsconsortium/bind9:9.11"
}

resource "docker_image" "bind9" {
  name          = data.docker_registry_image.bind9.name
  keep_locally  = var.keep_docker_images
  pull_triggers = [data.docker_registry_image.bind9.sha256_digest]
}

locals {
  files_to_upload = [ 
    "named.conf",
    "named.conf.local",
    "named.conf.options",
    "db.reliance.prospere.kiwi.nz",
    "db.homenet"
  ]
}
resource "docker_container" "bind9" {
  depends_on = [ docker_network.bind_network ]
  name    = "bind9"
  image   = docker_image.bind9.latest
  restart = "always"

  networks_advanced {
    name    = docker_network.bind_network.name
    aliases = [ "dns" ]
  }

  dynamic upload {
    for_each = local.files_to_upload
    content {
      file = "/etc/bind/${upload.value}"
      source = "conf/${upload.value}"
    }
  }

  # # DNS Endpoint
  # ports {
  #   internal = 53
  #   external = 1053
  # }

  # # DNS endpoint
  # ports {
  #   internal = "53"
  #   external = "1053"
  #   protocol = "udp"
  # }
}