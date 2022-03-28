terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    template = {
      source = "hashicorp/template"
    }
    shell = {
      source = "scottwinkler/shell"
    }
    powerdns = {
      source  = "pan-net/powerdns"
      version = "1.4.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.7.0"
    }
  }
  required_version = ">= 0.13"
}
