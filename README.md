# IaC Confluent Cloud Resource API Key Rotation Terraform module

**Table of Contents**

<!-- toc -->
+ [Purpose](#purpose)
    - [Module Input Variables](#module-input-variables)
    - [Module Output Variables](#module-output-variables)
+ [How to use this repo?](#how-to-use-this-repo)
+ [Important Note](#important-note)
+ [Resources](#resources)
<!-- tocstop -->

## Purpose
This Terraform [module](https://developer.hashicorp.com/terraform/language/modules) handles the creation and rotation of Confluent Cloud Resource [API Key](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html).  The rotation of keys is based on the number of days since creation and you can retain a configurable number of API Key per [Service Account](https://docs.confluent.io/cloud/current/access-management/identity/service-accounts/overview.html).

A Terraform module consists of [input](https://developer.hashicorp.com/terraform/language/values/variables) and [output](https://developer.hashicorp.com/terraform/language/values/outputs) variables, which enables me to customize aspects of the module without altering its source code.  This feature makes it easy for me to share the module across different Terraform configurations, allowing for composability and reusability.

### Module Input Variables
A Terraform configuration provides values for the module input variables to initiate the creation and rotation of the Confluent Cloud Resource API Key.  Below are the input variables:
Variable|Required|Description
-|-|-
`confluent_cloud_api_key`|Yes|Specifies the Confluent Cloud API Key (also referred as Cloud API ID)
`confluent_cloud_api_secret`|Yes|Specifies the Confluent Cloud API Secret
`day_count`|No|[_Defaults to 30 days_]  Specifies how many day(s) should the API Key be rotated for
`number_of_api_keys_to_retain`|No|[_Defaults to 2 API Keys_]  Specifies the number of API Keys to retain
`key_display_name`|No|[_Defaults to a display name with current date_]  Specifies the name of the human-readable name for the API Key
`owner`|Yes|Specifies the API Key Owner.  Refer to [Confluent API Key Docs](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_api_key#argument-reference) for more info 
`resource`|Yes|Specifies the API Key Resource associated with it.  Refer to [Confluent API Key Docs](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_api_key#argument-reference) for more details

### Module Output Variables
After the module is executed, it will output the following variables:
Variable|Description
-|-
`active_api_key`|Specifies the current active API Key to be used for new logins.  Refer to [confluent/confluent_api_key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_api_key) for the expected structure
`all_api_keys`|Specifies all API Keys sorted by creation date.  With the current active API Key being the 1st in the collection

## How to use this repo?
In the [main.tf](main.tf) replace **`<TERRAFORM CLOUD ORGANIZATION NAME>`** in the `terraform.cloud` block with your [Terraform Cloud Organization Name](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/organizations) and **`<TERRAFORM CLOUD ORGANIZATION's WORKSPACE NAME>`** in the `terraform.cloud.workspaces` block with your [Terraform Cloud Organization's Workspaces Name](https://developer.hashicorp.com/terraform/cloud-docs/workspaces).

## Important Note
> Due to the limitation of Terraform and Time Based rotation. You must execute the module regularly, on a frequency that is equal to or less than the configured number of days to rotate. If you do not, then you can run the risk of rotating out/deleting multiple API Keys on the next run. This can get to the extent that all your current API Keys are removed on a single run. This will prevent any current running process, that is currently using the older API Keys, from continuing to be able to log in and operate against your Confluent Cloud Resources.

## Resources
[Best Practices for Using API Keys on Confluent Cloud](https://docs.confluent.io/cloud/current/security/authenticate/workload-identities/service-accounts/api-keys/best-practices-api-keys.html)

[Nikoleta Verbeck shows how to use Terraform to rotate Confluent API Key(s)](https://github.com/nerdynick/terraform-confluent-api-key-rotation)

[Terraform Resource time_rotating](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating.html)

[Terraform Hidden Gems! Secret Rotation with time_rotating](https://medium.com/cloud-native-daily/terraform-hidden-gems-secret-rotation-with-time-rotating-72ae8683ef7f)
