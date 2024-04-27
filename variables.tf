

variable "rgname" {
  type        = string
  description = "resource group name"

}

variable "location" {
  type    = string
  description = "variable for resource location"
  default = "canadacentral"
}

variable "service_principal_name" {
  type = string
  description = "The Name of the Service Principal to create."
}

variable "keyvault_name" {
    type = string
}

variable "cluster-name" {
  type        = string
  description = "AKS cluster-name"

}