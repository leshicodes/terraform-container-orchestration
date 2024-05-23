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