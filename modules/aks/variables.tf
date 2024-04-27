variable "location" {
  description = "The location where the resources will be created."
}
variable "aks_cluster_name" {
  type        = string
  description = "Name of your AKS cluster"
}
variable "resource_group_name" {
  type        = string
  description = "Resource group name that the AKS cluster is located in"
}
variable "service_principal_name" {
  type = string
  description = "value for service principal application Id"
}
variable "ssh_public_key" {
  description = "value"
  default = "./.ssh/id_rsa.pub"
}
variable "client_id" {
  type=string
  description="Azure Service Principal client id"
}
variable "client_secret" {
  type      = string
  description = "value for Azure Service Principal password"
  sensitive = true
}
