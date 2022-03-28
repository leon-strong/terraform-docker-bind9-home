variable "keep_docker_images" {
  default = true
}

variable "external_name" {
  default = "zabbix.dyn.homenet"
}

variable "external_ip" {
  default = "192.168.183.1"
}

variable "postgres_user" {
  default = "zabbix"
}

variable "postgres_password" {
  default = "zabbix_password"
}

variable "keycloak_admin_user" {
  default = "admin"
}

## This needs to be the same as in the infra repo
variable "keycloak_admin_pw" {
  default = "keycloakadmin"
}

variable "keycloak_realm" {
  default = "Development"
}