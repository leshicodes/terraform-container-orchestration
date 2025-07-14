output "docker_networks" {
  value = docker_network.docker_networks
}

output "docker_images" {
  value = docker_image.docker_images
}

output "docker_containers" {
  value = docker_container.docker_containers
}

# Output dependency information for documentation/debugging
output "container_dependencies" {
  description = "Information about container dependencies (not enforced by Terraform)"
  value = {
    for file_path, config in local.docker_containers :
    config.container_name => lookup(config, "depends_on", [])
    if length(lookup(config, "depends_on", [])) > 0
  }
}