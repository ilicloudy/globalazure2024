This code is creating Static Web Site in Azure Storage Account with CDN endpoint and uploads a whole site with images, csv, html using module for storage blob.
Version 2.0.0

1. checkov -d .

2. tflint

3. terraform-docs

terraform-docs markdown table --output-file README.md --output-mode inject path_to_module
path_to_module is absolute path

4. terraform graph
terraform plan -out=tf.plan
output copy
then goto https://dreampuf.github.io/GraphvizOnline/ and paste content there -> output is visually presened and export it in svg/png


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.95.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.95.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_stblobcss"></a> [stblobcss](#module\_stblobcss) | ./modules/blob | n/a |
| <a name="module_stblobcsv"></a> [stblobcsv](#module\_stblobcsv) | ./modules/blob | n/a |
| <a name="module_stblobhtml"></a> [stblobhtml](#module\_stblobhtml) | ./modules/blob | n/a |
| <a name="module_stblobjs"></a> [stblobjs](#module\_stblobjs) | ./modules/blob | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_endpoint.cdnep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_endpoint) | resource |
| [azurerm_cdn_profile.cdnprofile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_profile) | resource |
| [azurerm_resource_group.rgst](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.stweb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.stblobimage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [random_string.stnamepostfix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_storage_container.stcontainer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group. | `string` | `"westeurope"` | no |
| <a name="input_rgname"></a> [rgname](#input\_rgname) | Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription. | `string` | `"rgst"` | no |
| <a name="input_stname"></a> [stname](#input\_stname) | Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription. | `string` | `"stname"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stweb_name"></a> [stweb\_name](#output\_stweb\_name) | n/a |
| <a name="output_stweb_web_endpoint"></a> [stweb\_web\_endpoint](#output\_stweb\_web\_endpoint) | n/a |
<!-- END_TF_DOCS -->