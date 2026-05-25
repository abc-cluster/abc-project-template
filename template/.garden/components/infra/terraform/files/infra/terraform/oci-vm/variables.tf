variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys_path" {}
variable "ubuntu_version" {
  default = "22.04"
}
variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}
variable "instance_display_name" {
  default = "tf-oci-instance"
}
