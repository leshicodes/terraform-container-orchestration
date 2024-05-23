variable "docker_network_config_files_path" {
  description = "Relative Path to the Path containing all JSON configuration files for Desired Docker Networks."
  type        = string
  default     = "config/networks/*.json"
}

variable "docker_container_config_files_path" {
  description = "Relative Path to the Path containing all JSON configuration files for Desired Docker Containers."
  type        = string
  default     = "config/containers/*.json"
}