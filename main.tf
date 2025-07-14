/*
  TODO : 
    * Figure out how to do the 'depends_on' meta argument. It typically requires a static list which is annoying.
*/

locals {
  # Get a list of all JSON files in the $docker_container_config_files_path directory
  docker_container_config_files = fileset("${path.root}", "${var.docker_container_config_files_path}")
  # Decode each JSON file into a map where the key is the filename and the value is the decoded JSON
  docker_containers = { for file in local.docker_container_config_files : file => jsondecode(file(file)) }

  # Get a list of all JSON files in the $docker_network_config_files_path directory
  docker_networks_config_files = fileset("${path.root}", "${var.docker_network_config_files_path}")
  # Decode each JSON file into a map where the key is the filename and the value is the decoded JSON
  docker_networks = { for file in local.docker_networks_config_files : file => jsondecode(file(file)) }
}


resource "docker_network" "docker_networks" {
  for_each = local.docker_networks

  name   = each.value.name
  driver = each.value.driver
}


# This will create docker_image resources for each Docker container defined in the JSON files.
resource "docker_image" "docker_images" {
  for_each = local.docker_containers

  # name         = each.value.image_target
  name         = join(":", [each.value.image.name, each.value.image.tag])
  keep_locally = lookup(each.value, "keep_image_locally", true)
}

resource "docker_container" "docker_containers" {
  for_each = local.docker_containers

  name  = each.value.container_name
  image = join(":", [each.value.image.name, each.value.image.tag])
  # Default hostname to the 'container_name' JSON KVP if there is not a 'hostname' KVP.   
  hostname   = lookup(each.value, "hostname", each.value.container_name)
  domainname = lookup(each.value, "domainname", each.value.container_name)
  restart    = lookup(each.value, "restart", "on-failure")
  must_run   = lookup(each.value, "must_run", true)
  gpus       = lookup(each.value, "gpus", null)

  # Dynamically allocate ports based on JSON config
  dynamic "ports" {
    # for_each = each.value.ports
    for_each = try(each.value.ports, {}) # The 'try' function allows the functionality of the JSON file NOT having the 'ports' block specified. If it is not there it simply wont apply this loop.
    content {
      internal = ports.value.internal
      external = ports.value.external
      protocol = lookup(ports.value, "protocol", "tcp")
    }
  }

  # Dynamically config advanced networking based on JSON config
  dynamic "networks_advanced" {
    for_each = each.value.networking
    content {
      name = networks_advanced.value.name
    }
  }

  # Dynamically allocate volumes based on JSON config
  dynamic "volumes" {
    # for_each = each.value.volumes
    for_each = try(each.value.volumes, {}) # The 'try' function allows the functionality of the JSON file NOT having the 'volumes' block specified. If it is not there it simply wont apply this loop.
    content {
      host_path      = volumes.value.host_path
      container_path = volumes.value.container_path
      read_only      = lookup(volumes.value, "read_only", false)
    }
  }

  # Dynamically allocate env vars based on JSON config
  env = [
    for env in each.value.env :
    "${env.name}=${lookup(env, "value", "")}"
  ]

  # Dynamically allocate env vars based on JSON config
  # group_add = [
  #   for group_add in each.value.group_add :
  #   try("${group_add.name}=${lookup(group_add, "value", "")}", null)
  # ]

  # Dynamically config healthchecks based on JSON config
  dynamic "healthcheck" {
    # for_each = each.value.healthcheck
    for_each = try(each.value.healthcheck, {}) # The 'try' function allows the functionality of the JSON file NOT having the 'healthcheck' block specified. If it is not there it simply wont apply this loop.
    content {
      test     = split(" ", healthcheck.value.test)
      retries  = healthcheck.value.retries
      timeout  = healthcheck.value.timeout
      interval = healthcheck.value.interval
    }
  }

  # Dynamically config devices based on JSON config
  dynamic "devices" {
    for_each = try(each.value.devices, {}) # The 'try' function allows the functionality of the JSON file NOT having the 'devices' block specified. If it is not there it simply wont apply this loop.
    content {
      host_path      = devices.value.host_path
      container_path = devices.value.container_path
      permissions    = lookup(devices.value, "permissions", null)
    }
  }

  # Dynamically config capabilities based on JSON config
  dynamic "capabilities" {
    for_each = try(each.value.capabilities, {}) # The 'try' function allows the functionality of the JSON file NOT having the 'capabilities' block specified. If it is not there it simply wont apply this loop.
    content {
      # add = capabilities.value.add
      add  = lookup(capabilities.value, "add", null)
      drop = lookup(capabilities.value, "drop", null)
    }
  }

  # lifecycle {
  #   ignore_changes = [image]
  # }
}