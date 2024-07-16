terraform {
    cloud {
        organization ="<TERRAFORM CLOUD ORGANIZATION NAME>"

        workspaces {
            name = "<TERRAFORM CLOUD ORGANIZATION's WORKSPACE NAME>"
        }
  }

  required_providers {
        confluent = {
            source  = "confluentinc/confluent"
            version = "1.80.0"
        }
    }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

locals {
    now = timestamp()
    hour_count = var.day_count*24

    sorted_dates = sort(time_rotating.api_key_rotations.*.rfc3339)
    dates_and_count = zipmap(time_rotating.api_key_rotations.*.rfc3339, range(var.number_of_api_keys_to_retain))
    latest_api_key = lookup(local.dates_and_count, local.sorted_dates[0])
}

# This controls each key's rotations
resource "time_rotating" "api_key_rotations" {
    count = var.number_of_api_keys_to_retain
    rotation_days = var.day_count*var.number_of_api_keys_to_retain
    rfc3339 = timeadd(local.now, format("-%sh", (count.index)*local.hour_count))
}

# Store the retain API keys and the time when the rotation needs to accord  In order, to 
# trigger a `replace_triggered_by` on the API Key.  Refer to GitHub Issue for more info
# https://github.com/hashicorp/terraform-provider-time/issues/118
resource "time_static" "api_key_rotations" {
    count = var.number_of_api_keys_to_retain
    rfc3339 = time_rotating.api_key_rotations[count.index].rfc3339
}

# Create the Confluent Cloud Resouce API Key Pair based on the service account from the Confluent Cloud Resource 
# (e.g., Kafka Cluster or Schema Registry)
resource "confluent_api_key" "resouce_api_key" {
    count = var.number_of_api_keys_to_retain
    display_name = replace(var.key_display_name, "{date}", time_static.api_key_rotations[count.index].rfc3339)
    description  = "Creation of the Confluent Cloud Resource API Key managed by Terraform Cloud using Confluent Cloud Resource API Key Rotation Module"

    owner {
        id          = var.owner.id
        api_version = var.owner.api_version
        kind        = var.owner.kind
    }

    managed_resource {
        id          = var.resource.id
        api_version = var.resource.api_version
        kind        = var.resource.kind

        environment {
            id = var.resource.environment.id
        }
    }

    lifecycle {
        replace_triggered_by = [time_static.api_key_rotations[count.index]]
    }
}