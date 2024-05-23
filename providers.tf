terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  # Linux / MacOS
  host = "unix:///var/run/docker.sock"
  
  # Windows
  # host = "npipe:////.//pipe//docker_engine"
}