provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key_path    = var.private_key_path
  region              = var.region
}

resource "oci_core_virtual_network" "this" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "tf-vcn"
}

resource "oci_core_subnet" "this" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.this.id
  cidr_block          = "10.0.1.0/24"
  display_name        = "tf-subnet"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.this.id
  display_name   = "tf-igw"
}

resource "oci_core_default_route_table" "this" {
  manage_default_route_table = true
  vcn_id                    = oci_core_virtual_network.this.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.this.id
    assign_public_ip = true
    display_name     = "tf-vnic"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_authorized_keys_path)
    user_data           = filebase64("${path.module}/cloud-init.yaml")
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  display_name = var.instance_display_name
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu" {
  compartment_id = var.compartment_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = var.ubuntu_version
  shape = var.instance_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

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
