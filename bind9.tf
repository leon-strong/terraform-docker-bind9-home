
data "docker_registry_image" "bind9" {
  name = "internetsystemsconsortium/bind9:9.11"
}

resource "docker_image" "bind9" {
  name          = data.docker_registry_image.bind9.name
  keep_locally  = var.keep_docker_images
  pull_triggers = [data.docker_registry_image.bind9.sha256_digest]
}

data "template_file" "bind9_config" {
  template = "${file("${path.module}/templates/bind9.yaml")}"
  vars = {
    certificate_hostname = local.external_name
  }
}

resource "docker_container" "bind9" {
  depends_on = [
    docker_network.zabbix_frontend,
    docker_network.zabbix_apps
  ]
  name    = "zabbix_bind9"
  image   = docker_image.bind9.latest
  restart = "always"

  # dynamic "labels" {
  #   for_each = {
  #     "bind9.enable"                           = "true"
  #     "bind9.http.routers.bind9.rule"        = "Host(`${var.external_name}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
  #     "bind9.http.routers.bind9.service"     = "api@internal"
  #     "bind9.http.routers.bind9.entrypoints" = "dashboard"
  #     "bind9.http.routers.bind9.tls"         = "true"
  #     "bind9.docker.network"                   = docker_network.zabbix_apps.name
  #   }
  #   content {
  #     label = labels.key
  #     value = labels.value
  #   }
  # }

  # Let bind9 See our container events.
  volumes {
    volume_name    = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name    = docker_network.zabbix_apps.name
    aliases = [ local.external_name ]
  }

  # We bind to all our frontend network, and to the application network
  # so that we can access our internal services.

  networks_advanced {
    name         = docker_network.zabbix_frontend.name
    ipv4_address = "192.168.183.1"
    aliases      = [data.terraform_remote_state.ca.outputs.external_name]
  }

  upload {
    content = file("${path.module}/templates/bind9-ssl.yaml")
    file    = "/etc/bind9/bind9-ssl.yaml"
  }

  upload {
    content = data.template_file.bind9_config.rendered
    file    = "/etc/bind9/bind9.yaml"
  }

  upload {
    content = "${data.terraform_remote_state.ca.outputs.certs[data.terraform_remote_state.ca.outputs.cert_name]}${data.terraform_remote_state.ca.outputs.ca}${data.terraform_remote_state.ca.outputs.intermediate}"
    file    = "/etc/ssl/cert.crt"
  }

  upload {
    content = data.terraform_remote_state.ca.outputs.keys[data.terraform_remote_state.ca.outputs.cert_name]
    file    = "/etc/ssl/cert.key"
  }

  # ports {
  #   internal = 8090
  #   external = 8090
  # }

  # ports {
  #   internal = 8080
  #   external = 8084
  # }
  # ports {
  #   internal = 80
  #   external = 8082
  # }

  # ports {
  #   internal = 443
  #   external = 8443
  # }

  # # DNS Endpoint
  # ports {
  #   internal = 53
  #   external = 1053
  # }

  # # ECTD endpoint
  # ports {
  #   internal = 2379
  #   external = 43379
  # }

  # # DNS endpoint
  # ports {
  #   internal = "53"
  #   external = "1053"
  #   protocol = "udp"
  # }

  labels {
    label = "external_url"
    value = "https://${var.external_name}"
  }
}
# We transform our labels into something a bit more usable elsewhere.

locals {
  bind9_labels = { for item in tolist(docker_container.bind9.labels) :
    item["label"] => item["value"]
  }
}

output labels {
  value = local.bind9_labels
}

output "external_ip" {
  value = var.external_ip
}
