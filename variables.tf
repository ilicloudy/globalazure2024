variable "location" {
  type        = string
  description = "Location of the resource group."
  default     = "westeurope"
  #contract test
  validation {
    condition     = can(regex("^(westeurope|uksouth)$", var.location))
    error_message = "Resources can only be provisioned in two regions West Europe and UKSouth"
  }
}

variable "rgname" {
  type        = string
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  default     = "rgst"
}

variable "stname" {
  type        = string
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  default     = "stname"
  #contract test
  validation {
    condition     = can(regex("[[:lower:]]", var.stname))
    error_message = "storage account should not have capital letters, special chars"
  }
}

/*variable "origin_url" {
  type        = string
  description = "URL of cdn endpoint"
  default     = "mysite.iicloudy.io"
}
*/

