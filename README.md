# terraform-container-orchestration

## Description 
This is a custom Terraform module designed to build and manage Docker containers and networks using data provided in JSON Configuration files. Examples for these JSON Parameter files are provided in the [./examples](./examples/) directory

## Requirements
* Terraform 0.15 or later
* Docker Engine installed and running on the local machine
* Terraform Docker Provider (optional, if not already installed)

## Usage 

### Input Parameters
| Name   | Description  | Default Value | type |
|---|---|---|---|
|  ```docker_network_config_files_path``` | Relative Path to the Path containing all JSON configuration files for Desired Docker Networks.  | config/networks/*.json  | string |
| ```docker_container_config_files_path```  | Relative Path to the Path containing all JSON configuration files for Desired Docker Containers.  | config/containers/*.json  | string |

### Invoking Module via Terraform Project

1. Insert the below code into your Terraform code.
    ```hcl
    module "terraform_container_orchestration" {
      source = "github.com/leshicodes/terraform-container-orchestration"

      docker_container_config_files_path = "<path to docker container json files here>"
      docker_network_config_files_path = "<path to docker network json files here>"
    }

    # OPTIONAL
    output "terraform_container_orchestration_output" {
      value = module.terraform_container_orchestration
    }
    ```
2. Run ```terraform init``` to download the module and initialize the Terraform environment.
3. Execute ```terraform plan``` to refresh the state and run a plan. 
4. When the plan looks good, apply it with ```terraform apply```

### Container JSON File Syntax

| Item | Data Type | Description |
| --- | --- | --- |
| **image** | Object | Docker Image Object ; Contains `name` and `tag` properties |
| **keep_image_locally** | Boolean | True or false value indicating whether to keep the image locally |
| **container_name** | String | Name of the container |
| **env** | Array of Objects | List of environment variables, each with `name` and `value` properties |
| **ports** | Array of Objects | List of port configurations, each with `internal`, `external`, and `protocol` properties |
| **networking** | Array of Strings | List of network names (e.g., "mediaserver_network") |
| **volumes** | Array of Objects | List of volume mounts, each with `host_path` and `container_path` properties |
| **healthcheck** | Array of Objects | List of health checks, each with `test`, `retries`, `timeout`, and `interval` properties |
| **devices** | Array | Empty array (no data) |
| **capabilities** | Array | Empty array (no data) |

### Container Dependencies

The JSON schema supports a `depends_on` array to document container dependencies, but due to Terraform limitations, these dependencies aren't enforced during deployment. Instead:

- Use proper restart policies in your containers
- Implement health checks where possible
- Design services with retry logic for dependent services

To see the documented dependencies, check the `container_dependencies` output.